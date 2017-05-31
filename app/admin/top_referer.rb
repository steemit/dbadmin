ActiveAdmin.register_page "Top Refer" do

  content title: "Top 100 Clicked Links/Sources" do
    table_for UserAttributes.referer_only.group(:value).count.sort { |x,y| x[0] <=> y[0] }.reverse.first(100).each do
      column "count" do |r|
        r[1]
      end
      column "value" do |r|
        r[0]
      end
    end
  end

end
