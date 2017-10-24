ActiveAdmin.register UserPreference do
  menu label: 'User Preferences'
  index :download_links => false do
    column :id
    column :account
    column :json
    column :created_at
    actions defaults: false do |a|
      item 'View', admin_user_preference_path(a)
    end
  end

end
