class List < ActiveRecord::Base
  self.table_name = 'lists'
  validates :value, uniqueness: { scope: :kk }

  def mark_bots(email_provider)
    users = User.where("email LIKE '%#{email_provider}' and bot=0")
    counter = 0
    users.each do |u|
      puts "--- marking user as bot: ##{u.id} #{u.name} #{u.email}"
      u.bot = true
      u.save!
      counter += 1
    end
    return counter
  end

end
