ActiveAdmin.register List, as: 'Value' do
  menu label: 'Vars/Params'
  index do
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

  filter :kk
  filter :value
  filter :created_at

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
