class List < ActiveRecord::Base
  self.table_name = 'lists'

  def mark_bots(email_provider)
    users = User.where("email LIKE '%#{email_provider}'")
    users.each do |u|
      puts "--- marking user as bot: ##{u.id} #{u.name} #{u.email}"
      u.bot = true
      u.save!
    end
    return users.count
  end

end
