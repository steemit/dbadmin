ActiveAdmin.register Identity do
    scope :all

    index do
        column :id
        column :user do |rec|
            rec.user ? link_to(rec.user.email || rec.email, admin_user_path(rec.user_id)) : nil
        end
        # column :name
        column :provider
        column :email_or_phone do |rec|
          rec.email || rec.display_phone
        end
        column :verified
        column :score
        column :created_at
        actions defaults: false do |a|
            item 'View', admin_identity_path(a)
        end
    end
    filter :name
    filter :email
    filter :phone
    filter :score
    filter :verified
    filter :created_at
    filter :provider, as: :check_boxes, collection: ['email', 'phone', 'facebook', 'reddit']
    filter :score, as: :numeric

    form do |f|
      f.inputs do
        f.input :provider
        f.input :name
        f.input :email
        f.input :phone
        f.input :score
        f.input :verified
        f.input :confirmation_code
      end
      f.actions
    end
    permit_params :provider, :name, :email, :phone, :score, :verified, :confirmation_code
end
