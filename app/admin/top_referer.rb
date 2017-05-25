ActiveAdmin.register_page "Top Refer" do

  content title: "Top Clicked Links/Sources" do
    table_for UserAttributes.referer_only.limit(100).pluck(:value).group_by {|r| r}.values.sort.reverse.each do
      column "count" do |r|
        r.count
      end
      column "value" do |r|
        r.first
      end
    end
  end
end
