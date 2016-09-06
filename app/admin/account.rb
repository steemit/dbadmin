ActiveAdmin.register Account do
  index do
    column :id
    column :user_id
    column :name
    column :remote_ip
    column :referrer
    column :created_at
    actions defaults: false do |a|
      item 'View', admin_account_path(a)
    end
  end
  filter :name
  filter :referrer
  filter :created_at
end
