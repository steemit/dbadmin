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
      u.display_email
    end
    column :phone do |u|
      u.display_phone
    end
    column :issues do |u|
      u.phone_warning ? status_tag('Phone', :warning) : ''
    end
    column :account
    column :created_at
    actions
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
        u.phone_warning
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
        column :ignored, as: :check_box
        column :created_at
      end
    end
    default_main_content
  end

  filter :name
  filter :email
  filter :created_at
  filter :updated_at

  form do |f|
    f.inputs "User Details" do
      f.input :email
      f.input :waiting_list
      f.input :bot
    end
    f.actions
  end
  permit_params :email, :waiting_list, :bot

  member_action :invite, :method => :put do
  end

  controller do
    # def scoped_collection
    #   User.eager_load(:identities).where('users.id > 135310')
    # end
    def invite
      @user = User.find(params[:id])
      @user.invite!
      redirect_to action: "show", id: @user.id
    end
  end


end
