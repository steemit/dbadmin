ActiveAdmin.register Account do
  index do
    column :id
    column :user_id
    column :name
    column :remote_ip
    column :referrer
    column :ignored, as: :check_box
    column :created_at
    actions defaults: false do |a|
      item 'View', admin_account_path(a)
      item 'Edit', edit_admin_account_path(a)
    end
  end

  filter :name
  filter :referrer
  filter :created_at

  form do |f|
    f.inputs "Account Details" do
      f.input :ignored
    end
    f.actions
  end
  permit_params :ignored
end
