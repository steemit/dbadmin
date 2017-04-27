class Account < ActiveRecord::Base
    belongs_to :user
    scope :bot, -> { joins(:user).where('users.bot=1') }

    def ignore!
        self.update_attributes(ignored: true)
    end

    def display_name
      self.name
    end

end
