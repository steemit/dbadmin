ActiveAdmin.register Account do
  scope :all
  scope :bot
  index do
    column :id
    column :user_id
    column :name
    column :remote_ip
    column :referrer
    column :created do |a|
        a.created.nil? ? '-' : status_tag(a.created, a.created ? :yes : :no)
    end
    column :ignored, as: :check_box
    column :updated_at
    actions defaults: false do |a|
      item 'View', admin_account_path(a)
      item 'Edit', edit_admin_account_path(a)
      item 'Ignore', ignore_admin_account_path(a), method: :put
    end
  end

  filter :name
  filter :referrer
  filter :created_at

  form do |f|
    f.inputs "Account Details" do
      f.input :ignored
      f.input :created
    end
    f.actions
  end
  permit_params :ignored, :created

  member_action :ignore, :method => :put do
  end

  controller do
    def ignore
      a = Account.find(params[:id])
      a.ignore!
      flash[:notice] = 'Account has been updated'
      redirect_to admin_user_path(a.user)
    end
  end

end
