ActiveAdmin.register User do
  # scope :all
  # scope :waiting_list
  includes :identities

  index do
    # column :pic do |u|
    #   image_tag u.picture_small, size: "32x32"
    # end
    column :id
    # column :name
    column :location
    column :email do |u|
       u.email_identity ? text_with_checkmark(u.display_email, 'Confirmed', u.email_identity.verified) : nil
    end
    column :phone do |u|
      u.phone_identity ? text_with_checkmark(u.display_phone, 'Confirmed', u.phone_identity.verified).html_safe + content_tag(:span, ' ' + u.phone_identity.score.to_s, title: 'TeleSign Score', class: 'small quiet')  : nil
    end
    column :issues do |u|
      u.issues.each do |k, v|
        status_tag(k, :warning, :title => v) unless v.blank?
      end
      nil
    end
    column :account
    column :account_status do |u|
      render_account_status_tag(u, self)
    end
    column :created_at
    actions defaults: false do |u|
      item('View', admin_user_path(u), method: :get)
      if u.account_status == 'waiting'
        if u.can_be_approved? then item('Approve', approve_admin_user_path(u), method: :put) end
        item('Reject', reject_admin_user_path(u), method: :put)
      elsif u.account_status == 'approved'
        item('Reject', reject_admin_user_path(u), method: :put)
      elsif u.account_status == 'rejected'
        if u.can_be_approved? then item('Approve', approve_admin_user_path(u), method: :put) end
      end
    end
  end

  show do
    attributes_table do
      row :id
      row :location
      row :email
      row :phone do |u|
        u.display_phone
      end
      row :issues do |u|
        u.issues.select{|k, v| v}.map{|k,v| v}.join('; ')
      end
    #   row :name
    #   row :picture do |u|
    #     if u.picture_small
    #         image_tag u.picture_small, size: "128x128"
    #     else
    #         '-'
    #     end
    #   end
      row :invitation_link do |rec|
        if rec.email_identity
          if rec.email_identity.confirmation_code
            text_field_tag 'invitation_link', "https://steemit.com/start/#{rec.email_identity.confirmation_code}",  size: 60, disabled: true
          else
            link_to('Generate', invite_admin_user_path(rec), method: :put)
          end
        else
          link_to('Generate', invite_admin_user_path(rec), method: :put)
        end
      end
      row :account_status do |u|
        render_account_status_tag(u, self)
      end
      row :actions do |u|
        link_to('Approve', approve_admin_user_path(u), method: :put).html_safe + ' &nbsp; | &nbsp; '.html_safe +
        link_to('Reject', reject_admin_user_path(u), method: :put).html_safe
      end
    end
    panel "Identities" do
      table_for user.identities do
        column :id do |i|
          link_to i.id, admin_identity_path(i)
        end
        column :email_or_phone do |rec|
          rec.email.blank? ? rec.phone : rec.email
        end
        column :provider
        column :confirmation_code
        column :verified
        column :score
        column :created_at
        column :updated_at
      end
    end
    panel "Accounts" do
      table_for user.accounts do
        column :id do |a|
          link_to a.id, admin_account_path(a)
        end
        column :name
        column :created do |a|
            a.created.nil? ? '-' : status_tag(a.created, a.created ? :yes : :no)
        end
        column :ignored, as: :check_box
        column :actions do |a|
          link_to('Ignore', ignore_admin_account_path(a), method: :put)
        end
        column :created_at
        column :updated_at
      end
    end
    panel "Other signups used the same phone and email" do
      table_for user.other_users do
        column :display_name do |u|
          link_to u.display_name, admin_user_path(u)
        end
        column :account
        column :account_status do |u|
          render_account_status_tag(u, self)
        end
        column :created_at
        column :updated_at
      end
    end
    panel "User Attributes" do
      table_for UserAttributes.where(user_id: user.id) do
        column :type_of
        column :value
        column :created_at
        column :updated_at
      end
    end
    default_main_content
  end

  filter :name
  filter :email
  filter :account_status, as: :check_boxes, collection: ['waiting', 'approved', 'rejected', 'created', 'onhold', 'discarded']
  filter :created_at
  filter :updated_at

  action_item do
    link_to "Auto-process All", auto_approve_everyone_admin_users_path(params), :method => :put
  end
  action_item do
    link_to "Auto-approve All w/o Issues", auto_approve_admin_users_path(params), :method => :put
  end

  form do |f|
    f.inputs "User Details" do
      f.input :email
      f.input :waiting_list
      f.input :bot
    end
    f.actions
  end
  permit_params :email, :waiting_list, :bot

  member_action :invite, :method => :put
  member_action :approve, :method => :put
  member_action :reject, :method => :put
  collection_action :auto_approve, :method => :put
  collection_action :auto_approve_everyone, :method => :put

  controller do

    def invite
      @user = User.find(params[:id])
      @user.invite!
      redirect_to action: "show", id: @user.id
    end

    def approve
      @user = User.find(params[:id])
      result = @user.approve
      if result[:error]
        flash[:error] = "Failed to approve user #{@user.email} - #{result[:error]}"
      else
        flash[:notice] = "Approved user #{@user.email}"
      end

      redirect_to :back
    end

    def reject
      @user = User.find(params[:id])
      @user.reject!
      flash[:notice] = "Rejected user #{@user.email}"
      redirect_to :back
    end

    def auto_approve
      approved = 0
      errors = 0
      collection.each do |user|
        next unless user.account_status == 'waiting'
        next unless user.account
        eid = user.email_identity
        next unless eid
        next unless eid.verified
        pid = user.phone_identity
        next unless pid
        next unless pid.verified
        issues = user.issues
        next if !issues[:phone].blank? or !issues[:email].blank?
        result = user.approve
        if result[:error]
          errors += 1
        else
          approved += 1
        end
      end
      flash_type = errors > 0 ? :error : :notice
      flash[flash_type] = "Auto-approved #{approved} accounts." + (errors > 0 ? " Errors: #{errors}" : "")
      redirect_to :back
    end

    def auto_approve_everyone
      approved = 0
      errors = 0
      collection.each do |user|
        next unless user.account_status == 'waiting'
        next unless user.account
        eid = user.email_identity
        pid = user.phone_identity
        if !eid or !pid
            user.putonhold!
            next
        end
        if eid.verified and pid.verified
          can_be_approved = true
          user.other_users.each do |u|
            if u.account_status == 'waiting' or u.account_status == 'approved' or u.account_status == 'onhold'
              u.discard!
            elsif u.account_status == 'created' or u.account_status == 'rejected'
              can_be_approved = false
            end
          end
          if can_be_approved
            result = user.approve
            if result[:error]
              errors += 1
            else
              approved += 1
            end
          else
            user.discard!
          end
        else
          user.putonhold!
        end
      end
      flash_type = errors > 0 ? :error : :notice
      flash[flash_type] = "Auto-approved #{approved} accounts." + (errors > 0 ? " Errors: #{errors}" : "")
      redirect_to :back
    end

  end

end
