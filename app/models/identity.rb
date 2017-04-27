require 'securerandom'

class Identity < ActiveRecord::Base
    belongs_to :user

    def generate_confirmation_code!
      update_attribute(:confirmation_code, SecureRandom.uuid)
    end

    def get_phone
      return @phlb = Phonelib.parse(phid.phone)
    end

    def display_phone
      phone ? Phonelib.parse(phone).full_international : nil
    end

end
