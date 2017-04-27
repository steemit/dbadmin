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

    def display_email
        return self.email if self.email
        eid = self.identities.find_by(provider: 'email')
        return eid ? eid.email : '-'
    end

    def get_phone
      return @phone if @phone or @phone == false
      phid = self.identities.find_by(provider: 'phone')
      unless phid
        @phone = false
        return @phone
      end
      return @phone = Phonelib.parse(phid.phone)
    end

    def display_phone
      phone = get_phone
      return phone ? phone.full_international : '-'
    end

    def phone_warning
      phone = get_phone
      cc = country_code
      return nil if not phone or cc == '-'
      unless phone.countries.include? cc
        return "User IP's country (#{cc}) doesn't match phone's (#{phone.countries.join(', ')})"
      end
      return nil
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
        @georec = @@geodb.lookup(remote_ip) unless @georec
        return @georec ? "#{@georec[:city]}, #{@georec[:region_name]}, #{@georec[:country_name]}" : '-'
    end

    def country
        return '' unless remote_ip
        @georec = @@geodb.lookup(remote_ip) unless @georec
        return @georec ? @georec[:country_name] : '-'
    end

    def country_code
        return '' unless remote_ip
        @georec = @@geodb.lookup(remote_ip) unless @georec
        return @georec ? @georec[:country_code] : '-'
    end

    def account
      self.accounts.where(:ignored => false).first
    end

end
