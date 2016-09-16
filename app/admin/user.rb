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
    end
    panel "Identities" do
      table_for user.identities do
        column :id do |i|
          link_to i.id, admin_identity_path(i)
        end
        column :email
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
end
