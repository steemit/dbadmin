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
        panel "Number of accounts (last 24 hours)" do
            text_node Account.select("count(*) as cnt").where("created_at >= (NOW() - INTERVAL 1 DAY)").take.cnt
        end

        panel "Number of accounts (last 20 days)" do
          table_for Account.select("DATE(created_at) as date, count(*) as cnt").group(:date).order("date desc").limit(30) do
            column :date do |r|
              r.date.strftime("%m/%d/%Y")
            end
            column :count do |r|
              r.cnt
            end
          end
        end
     end

     # select permlink, views from pages where created_at >= (NOW() - INTERVAL 1 DAY) order by views desc limit 20;

     column do
        panel "Popular Pages (last 24 hours)" do
          table_for Page.select("permlink, views").where("created_at >= (NOW() - INTERVAL 1 DAY)").order("views desc").limit(30) do
            column :permlink do |p|
              link_to(p.permlink, "https://steemit.com" + p.permlink, target: "_blank")
            end
            column :views
          end
        end
      end

     column do
        panel "Recent Users" do
          table_for User.order("created_at desc").limit(30) do
            column :email do |u|
              link_to u.email, admin_user_path(u)
            end
            column :created_at
          end
          strong { link_to "View All Users", admin_users_path }
        end
      end

      column do
        panel "Recent Accounts" do
          table_for Account.order("created_at desc").limit(30) do
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
