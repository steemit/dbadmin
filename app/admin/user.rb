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
      row :picture do |u|
        image_tag u.picture_small, size: "128x128"
      end
    end
    default_main_content
  end

  filter :name
  filter :email
  filter :created_at
  filter :updated_at
end
