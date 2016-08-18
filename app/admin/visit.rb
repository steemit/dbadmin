ActiveAdmin.register WebEvent, as: "Visit" do
  config.sort_order = 'created_at_desc'
  #actions :all, except: [:update, :destroy]
  #default_scope :visit
  controller do
    def scoped_collection
      WebEvent.visit
    end
  end


  index do
    column :created_at
    #column :event_type
    column 'Page', :value
    #column :uid
    #column :first_visit
    #column :status
    column :refurl
    column :referrer
    column :channel
    column :campaign
  end

  filter :created_at
  filter :refurl
  filter :referrer
  filter :channel
  filter :campaign

end
