ActiveAdmin.register List do
  index do
    column :id
    column :kk
    column :value
    column :created_at
    actions :defaults
  end

  filter :kk
  filter :value
  filter :created_at
end
