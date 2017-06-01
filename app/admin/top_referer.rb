ActiveAdmin.register_page "Top Refer" do

  content title: "Top 100 Clicked Links/Sources" do
    table_for UserAttributes.referer_only.value_only.group(:value).count.sort_by{|x| x[1]}.first(100).reverse.each do
      column "count" do |r|
        r[1]
      end
      column "value" do |r|
        r[0]
      end
    end
  end

end
