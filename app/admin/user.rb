def text_with_checkmark(text, title, checkmark)
  if checkmark
    icon = '&#10004;'.html_safe
    color = '#0c0'
    checkmark = content_tag(:span, icon, :style => "color: #{color}; cursor: default;", title: title)
    return text ? "#{text} #{checkmark}".html_safe : checkmark
  else
    text
  end
end

def issues_to_status_tags(warnings)
  return '' if warnings.empty?
  res = ''
  puts warnings.inspect
  warnings.each do |k, v|
    status_tag(k, :warning, :title => v)
  end
  return res
end

ActiveAdmin.register User do
  scope :all
  scope :waiting_list
  includes :identities

  index do
    # column :pic do |u|
    #   image_tag u.picture_small, size: "32x32"
    # end
    column :id
    # column :name
    column :country
    column :email do |u|
       u.email_identity ? text_with_checkmark(u.display_email, 'Confirmed', u.email_identity.verified) : nil
    end
    column :phone do |u|
      u.phone_identity ? text_with_checkmark(u.display_phone, 'Confirmed', u.phone_identity.verified) : nil
    end
    column :issues do |u|
      u.issues.each do |k, v|
        status_tag(k, :warning, :title => v) unless v.blank?
      end
      nil
    end
    column :account
    column :account_status do |u|
      color = case u.account_status
      when 'approved'
        :ok
      when 'waiting'
        :orange
      when 'rejected'
        :red
      when 'created'
        :yes
      else
        :no
      end
      status_tag(u.account_status, color)
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
        if rec.accounts.first and !rec.accounts.first.ignored
          'Already has account'
        elsif rec.email_identity
          if rec.email_identity.verified and rec.phone_identity and rec.phone_identity.verified and !rec.waiting_list
            rec.email_identity.confirmation_code ? "https://steemit.com/confirm_email/#{rec.email_identity.confirmation_code}" : "https://steemit.com/create_account"
          else
            if rec.phone_identity and rec.phone_identity.verified and !rec.email_identity.confirmation_code.blank?
              "https://steemit.com/confirm_email/#{rec.email_identity.confirmation_code}"
            else
              link_to('Generate', invite_admin_user_path(rec), method: :put)
            end
          end
        else
          link_to('Generate', invite_admin_user_path(rec), method: :put)
        end
      end
    end
    panel "Identities" do
      table_for user.identities do
        column :id do |i|
          link_to i.id, admin_identity_path(i)
        end
        column :email_or_phone do |rec|
          rec.email || rec.phone
        end
        column :provider
        column :verified
        column :score
        column :updated_at
        column :created_at
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
        column :updated_at
      end
    end
    default_main_content
  end

  filter :name
  filter :email
  filter :account_status, as: :check_boxes, collection: ['waiting', 'approved', 'rejected', 'created']
  filter :created_at
  filter :updated_at

  action_item do
    link_to "Auto-approve Page", auto_approve_admin_users_path(params), :method => :put
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

  controller do
    # def scoped_collection
    #   User.eager_load(:identities).where('users.id > 135310')
    # end
    def invite
      @user = User.find(params[:id])
      @user.invite!
      redirect_to action: "show", id: @user.id
    end
    def approve
      @user = User.find(params[:id])
      @user.approve!
      flash[:notice] = "Approved user #{@user.email}"
      redirect_to :back
    end
    def reject
      @user = User.find(params[:id])
      @user.reject!
      flash[:notice] = "Rejected user #{@user.email}"
      redirect_to :back
    end
    def auto_approve
      start_page = params[:page] ? params[:page].to_i - 1 : 0
      order = params[:order] || 'id_desc'
      approved = 0
      User.order(order.gsub('_', ' ')).offset(start_page * per_page).limit(per_page).each do |user|
        next unless user.account_status == 'waiting'
        eid = user.email_identity
        next unless eid
        next unless eid.email and eid.email.match(/@(gmail|yahoo|hotmail|outlook)\.com$/i)
        next unless eid.verified

        pid = user.phone_identity
        next unless pid
        next unless pid.score and pid.score < 400
        next unless user.get_phone.countries.include?('US')
        next unless user.country_code == 'US'

        user.approve!
        approved += 1
      end

      flash[:notice] = "Auto-approved #{approved} accounts."
      redirect_to :back
    end
  end


end
