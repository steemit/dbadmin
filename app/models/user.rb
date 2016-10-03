require 'securerandom'

class User < ActiveRecord::Base
    has_many :accounts, dependent: :destroy
    has_many :identities, dependent: :destroy

    scope :waiting_list, -> { where(:waiting_list => 1) }

    def email_identity
      self.identities.find_by(provider: 'email')
    end

    def generate_email_identity!
      self.identities.create(confirmation_code: SecureRandom.uuid, provider: 'email')
    end
end
