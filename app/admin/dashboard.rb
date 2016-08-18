ActiveAdmin.register_page "Dashboard" do

  menu priority: 1, label: proc { I18n.t("active_admin.dashboard") }

  content title: proc { I18n.t("active_admin.dashboard") } do
    # div class: "blank_slate_container", id: "dashboard_default_message" do
    #   span class: "blank_slate" do
    #     span I18n.t("active_admin.dashboard_welcome.welcome")
    #     small I18n.t("active_admin.dashboard_welcome.call_to_action")
    #   end
    # end

    columns do
      column do
        panel "Recent Users" do
          table_for User.order("created_at desc").limit(30) do
            column :id do |u|
              link_to u.id, admin_user_path(u)
            end
            column :name do |u|
              u.name && (link_to u.name, admin_user_path(u))
            end
            column :email
            column :created_at
          end
          strong { link_to "View All Users", admin_users_path }
        end
      end

      column do
        panel "Recent Accounts" do
          table_for Account.order("created_at desc").limit(30) do
            column :id do |a|
              link_to a.id, admin_account_path(a)
            end
            column :name do |a|
              link_to a.name, admin_account_path(a)
            end
            column :created_at
          end
          strong { link_to "View All Accounts", admin_accounts_path }
        end
      end
    end


    # Here is an example of a simple dashboard with columns and panels.
    #
    # columns do
    #   column do
    #     panel "Recent Accounts" do
    #       ul do
    #         Account.recent(50).map do |a|
    #           li link_to(a.name, admin_account_path(a))
    #         end
    #       end
    #     end
    #   end
    # end

    #   column do
    #     panel "Info" do
    #       para "Welcome to ActiveAdmin."
    #     end
    #   end
    # end
  end # content
end
