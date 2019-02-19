ActiveAdmin.register Arec do
  menu label: 'Account recovery'
  # scope :all
  # scope :by_email

  index :download_links => false do
    column :id
    column :user_id
    column :account do |rec|
      account = rec.account
      account ? link_to(rec.account_name, admin_account_path(rec.account)) : rec.account_name
    end
    column :contact_email do |rec|
       text_with_checkmark(rec.contact_email, 'Email matches original email', rec.email_match?)
    end
    column :owner_key
    column(:approved) do |rec|
      rec.approved? ? status_tag( "yes", :ok ) : status_tag( "no" )
    end
    column(:recovered) do |rec|
      rec.request_submitted_at ? status_tag( "yes", :ok ) : status_tag( "no" )
    end
    column(:was_recently_recovered) do |rec|
      rec.was_recently_recovered ? status_tag( "y", :red ) : status_tag( "n" )
    end
    column :created_at
    actions do |rec|
      if rec.approved?
        link_to('Recover Link', 'https://wallet.steemit.co/account_recovery_confirmation/' + rec.validation_code)
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
        @arec.approve!(current_admin_user)
        flash[:notice] = 'Your approved account recovery request'
      else
        flash[:notice] = 'Account recovery request was already approved, please reuse the link below!'
      end
    end
  end

end
