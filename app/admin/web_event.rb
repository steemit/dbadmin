ActiveAdmin.register WebEvent do
  menu label: 'Events'
  index index :download_links => false do
    column :id
    column :event_type
    column :value
    column :created_at
    actions defaults: false do |a|
      item 'View', admin_web_event_path(a)
    end
  end

  filter :event_type, as: :check_boxes, collection: ['csp_violation', 'client_error', 'api/login_account', 'login_attempt']

end
