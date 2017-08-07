ActiveAdmin.register Identity do
    # scope :all
    includes :user

    index do
        column :id
        column :user do |rec|
            rec.user ? link_to(rec.user.email || rec.user_id, admin_user_path(rec.user_id)) : rec.user_id
        end
        column :location do |rec|
          rec.user and rec.user.location
        end
        column :provider
        column :email_or_phone do |rec|
          rec.email || rec.display_phone
        end
        column :verified
        column :score
        column :account_status do |rec|
            render_account_status_tag(rec.user, self)
        end
        column :created_at
        actions defaults: false do |a|
            item 'View', admin_identity_path(a)
            u = a.user
            if u
              if u.account_status == 'waiting'
                if u.can_be_approved? then item('Approve', approve_admin_user_path(u), method: :put) end
                item('Reject', reject_admin_user_path(u), method: :put)
              elsif u.account_status == 'approved'
                item('Reject', reject_admin_user_path(u), method: :put)
              elsif u.account_status == 'rejected'
                if u.can_be_approved? then item('Approve', approve_admin_user_path(u), method: :put) end
              end
            end
        end
    end
    filter :name
    filter :email
    filter :phone
    filter :score
    filter :confirmation_code
    filter :verified
    filter :created_at
    filter :provider, as: :check_boxes, collection: ['email', 'phone'] #, 'facebook', 'reddit']
    filter :score, as: :numeric
    # filter :account_status, as: :check_boxes, collection: ['waiting', 'approved', 'rejected', 'created']

    action_item do
      link_to "Approve All", approve_all_admin_identities_path(params), :method => :put
    end
    action_item do
      link_to "Reject All", reject_all_admin_identities_path(params), :method => :put
    end

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

    collection_action :approve_all, :method => :put
    collection_action :reject_all, :method => :put

    controller do
        def approve_all
          approved = 0
          errors = 0
          collection.each do |i|
            user = i.user
            next unless user.account_status == 'waiting'
            next unless user.account
            eid = user.email_identity
            next unless eid
            result = user.approve
            if result[:error]
              errors += 1
            else
              approved += 1
            end
          end
          flash_type = errors > 0 ? :error : :notice
          flash[flash_type] = "Approved #{approved} users." + (errors > 0 ? " Errors: #{errors}" : "")
          redirect_to :back
        end
        def reject_all
          count = 0
          collection.each do |i|
            next unless i.user.account_status == 'waiting'
            i.user.reject!
            count += 1
          end
          flash[:notice] = "Rejected #{count} users."
          redirect_to :back
        end
    end

end
