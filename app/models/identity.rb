require 'securerandom'

class Identity < ActiveRecord::Base
    belongs_to :user

    def generate_confirmation_code!
      update_attribute(:confirmation_code, SecureRandom.uuid)
    end
end
