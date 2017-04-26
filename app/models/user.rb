require 'securerandom'
require 'geoip2_compat'


class User < ActiveRecord::Base
    @@geodb = GeoIP2Compat.new(Rails.root.join('GeoLite2-City.mmdb').to_s)

    has_many :accounts, dependent: :destroy
    has_many :identities, dependent: :destroy

    scope :waiting_list, -> { where(:waiting_list => 1) }

    def email_identity
      self.identities.find_by(provider: 'email')
    end

    def phone_identity
      self.identities.find_by(provider: 'phone')
    end

    def invite!
      if email_identity
        if email_identity.confirmation_code.blank?
          email_identity.generate_confirmation_code!
        end
      else
        self.identities.create(confirmation_code: SecureRandom.uuid, provider: 'email')
      end

      if !phone_identity
        self.identities.create(verified: true, provider: 'phone')
      elsif !phone_identity.verified
        phone_identity.update_attribute(:verified, true)
      end

    end

    def display_name
      name or email
    end

    def location
        return '' unless remote_ip
        res = @@geodb.lookup(remote_ip)
        puts 'location: ', remote_ip, res
        return res ? "#{res[:city]}, #{res[:region_name]}, #{res[:country_name]}" : '-'
    end


end
