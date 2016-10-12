ActiveAdmin.register User do
  scope :all
  scope :waiting_list

  index do
    column :pic do |u|
      image_tag u.picture_small, size: "32x32"
    end
    column :id
    column :name
    column :email
    column :created_at
    actions
  end

  show do
    attributes_table do
      row :id
      row :name
      row :picture do |u|
        image_tag u.picture_small, size: "128x128"
      end
      row :invitation_link do  |rec|
        if rec.accounts.first
          'Already has account'
        elsif rec.email_identity
          if rec.email_identity.verified and !rec.waiting_list
            "https://steemit.com/create_account"
          else
            if !rec.email_identity.confirmation_code.blank?
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
    def invite
      @user = User.find(params[:id])
      if @user.email_identity
        if @user.email_identity.confirmation_code.blank?
          @user.email_identity.generate_confirmation_code!
        end
      else
        @user.generate_email_identity!
      end
      redirect_to action: "show", id: @user.id
    end
  end

end
