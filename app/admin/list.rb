ActiveAdmin.register List, as: 'Value' do
  scope :all
  scope :blocked_emails
  scope :blocked_phones
  menu label: 'Vars/Params'
  index :download_links => false do
    column :id
    column 'Key', :kk
    column :value
    column :created_at
    actions do |rec|
      if rec.kk == 'block-email-provider'
        link_to('Mark all users as bots', mark_bots_admin_value_path(rec), method: :put)
      end
    end
  end

  show do
    attributes_table do
      row :kk
      row :value
      row :action do  |rec|
        if rec.kk == 'block-email-provider'
          link_to('Mark all users as bots', mark_bots_admin_value_path(rec), method: :put)
        end
      end
    end
    active_admin_comments
  end

  filter :kk, label: 'Key'
  filter :value
  filter :created_at

  form do |f|
    f.inputs do
      f.input :kk, label: 'Key'
      f.input :value
    end
    f.actions
  end

  permit_params :kk, :value

  member_action :mark_bots, :method => :put do
  end

  controller do
    def mark_bots
      @lr = List.find(params[:id])
      @count = @lr.mark_bots(@lr.value)
    end
  end

end
