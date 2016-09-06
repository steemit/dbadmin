ActiveAdmin.register Arec do
  scope :all
  scope :by_email

  index do
    column :id
    column :user_id
    column :account_name
    column :contact_email
    column :owner_key
    column :provider
    column :status
    column(:approved) do |rec|
      rec.approved? ? status_tag( "yes", :ok ) : status_tag( "no" )
    end
    column(:submitted) do |rec|
      rec.request_submitted_at ? status_tag( "yes", :ok ) : status_tag( "no" )
    end
    column :created_at
    actions do |rec|
      if rec.approved?
        link_to('Recover Link', 'https://steemit.com/account_recovery_confirmation/' + rec.validation_code)
      else
        link_to('Approve', approve_admin_arec_path(rec), method: :put)
      end
    end
  end

  filter :account_name
  filter :contact_email
  filter :provider
  filter :owner_key
  filter :created_at
  filter :updated_at

  member_action :approve, :method => :put do

  end

  controller do

    def approve
      @arec = Arec.find(params[:id])
      if !@arec.approved?
        @arec.approve!
        flash[:notice] = 'Your approved account recovery request'
      else
        flash[:notice] = 'Account recovery request was already approved, please reuse the link below!'
      end
    end

  end

end
