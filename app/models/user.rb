require 'securerandom'
require 'geoip2_compat'
require 'sendgrid-ruby'

class User < ActiveRecord::Base
    @@geodb = GeoIP2Compat.new(Rails.root.join('GeoLite2-City.mmdb').to_s)

    has_many :accounts, dependent: :destroy
    has_many :identities, dependent: :destroy

    scope :waiting_list, -> { where(:account_status => 'waiting') }

    def email_identity
      return @email_identity ||= self.identities.find_by(provider: 'email')
    end

    def phone_identity
      return @phone_identity ||= self.identities.find_by(provider: 'phone')
    end

    def display_email
        return self.email if self.email
        eid = email_identity
        return eid ? eid.email : '-'
    end

    def get_phone
      return @phone if @phone or @phone == false
      phid = phone_identity
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

    def phone_issue
      phone = get_phone
      cc = country_code
      return nil if not phone or cc == '-'
      unless phone.countries.include? cc
        return "User IP's country (#{cc}) doesn't match phone's (#{phone.countries.join(', ')})"
      end
      return nil
    end

    def email_issue
      eid = email_identity
      return 'Email is emepty' if !eid or eid.email.blank?
      parsed_email = eid.email.match(/^.+\@.*?([\w\d-]+\.\w+)$/)
      return 'Incorrect email' unless parsed_email
      blocked_provider = List.where(kk: 'block-email-provider', value: parsed_email[1]).first
      return 'Provider is in blacklist' if blocked_provider
      return nil
    end

    def issues
      {phone: phone_issue, email: email_issue}
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
      return @account ||= self.accounts.where(:ignored => false).first
    end

    def approve!
      eid = self.email_identity
      if !eid or eid.confirmation_code.blank? or eid.email.blank?
        logger.error "!!! Signup approve error: user's email not found [##{self.id}]"
        return
      end
      data = JSON.parse(%Q{{
        "personalizations": [
          {
            "to": [
              {
                "email": "#{eid.email}"
              }
            ],
            "substitutions": {
              "confirmation_code": "#{eid.confirmation_code}"
            },
            "subject": "Your Steemit account has been approved"
          }
        ],
        "from": {
          "email": "#{ENV['SDC_SENDGRID_FROM']}"
        },
        "template_id": "#{ENV['SDC_SENDGRID_APPROVETEMPLATE']}"
      }})
      sg = SendGrid::API.new(api_key: ENV['SDC_SENDGRID_API_KEY'])
      response = sg.client.mail._("send").post(request_body: data)
      logger.info "Sent signup approved email to #{eid.email} with status code #{response.status_code}"
      if response.status_code.to_i >= 300
        logger.error response.inspect
      end

      self.update_attribute(:account_status, 'approved')
    end

    def reject!
      self.update_attribute(:account_status, 'rejected')
    end

end
