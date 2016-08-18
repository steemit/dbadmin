ActiveAdmin.register Identity do
    index do
        column :id
        column :name
        column :email
        column :provider
        column :verified
        column :score
        column :created_at
        actions defaults: false do |a|
            item 'View', admin_account_path(a)
        end
    end
    filter :name
    filter :email
    filter :verified
    filter :created_at
    filter :provider, as: :check_boxes, collection: ['facebook', 'reddit']
    filter :score, as: :numeric
end
