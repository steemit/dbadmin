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

    # def self.in_account_status(status = 'waiting')
    #     Identity.all.select{|i| i.user.account_status == status }
    # end
    #
    # ransacker :account_status_in, proc{ |v|
    #     data = Identity.in_account_status(v).map(&:id)
    #     data = data.present? ? data : nil
    # } do |parent|
    #     parent.table[:id]
    # end

end
