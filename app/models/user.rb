require 'securerandom'
require 'geoip2_compat'
require 'sendgrid-ruby'

class User < ActiveRecord::Base
    @@geodb = GeoIP2Compat.new(Rails.root.join('GeoLite2-City.mmdb').to_s)

    has_many :accounts, dependent: :destroy
    has_many :identities, dependent: :destroy
    has_many :user_attributes, dependent: :destroy

    scope :waiting_list, -> { where(:account_status => 'waiting') }

    def email_identity
      return @email_identity ||= self.identities.where(provider: 'email').order('verified desc, id desc').first
    end

    def phone_identity
      return @phone_identity ||= self.identities.where(provider: 'phone').order('verified desc, id desc').first
    end

    def display_email
        eid = email_identity
        return eid ? eid.email : nil
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
      return 'Phone is empty; ' if not phone
      cc = country_code
      return 'Cannot detect country by IP (needed for phone verification); ' if cc.blank? or cc == '-'
      res = ''
      pi = phone_identity
      score_requirement = 400
      score_requirement = 900 if phone.countries.any?{|c| c == 'US' || c == 'GB' || c == 'AU' || c == 'BE' || c == 'FI' || c == 'FR' || c == 'DE' || c == 'IT' || c == 'NL' || c == 'NO' || c == 'ES' || c == 'SE' || c == 'CH' }
      if pi and pi.score and pi.score >= score_requirement
        res = "TeleSign score is too high: #{phone_identity.score}; "
      elsif !pi or !pi.score
        res = "There is no phone or no TeleSign score; "
      end
      if phone.countries and !phone.countries.empty? and !phone.countries.include? cc
        res << "\nUser IP's country (#{cc}) doesn't match phone's (#{phone.countries.join(', ')}); "
      end
      unless phone_identity.phone.blank?
        List.blocked_phones.each do |prefix|
          if phone_identity.phone.start_with? prefix.value
            res << "Blacklist match: #{prefix.value}; "
          end
        end
      end
      return res
    end

    def email_issue
      eid = email_identity
      return 'Email is empty' if !eid or eid.email.blank?
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
          email_identity.update_attribute(:verified, true)
        end
      else
        self.identities.create(confirmation_code: SecureRandom.uuid, provider: 'email', verified: true, email: self.email)
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
      return @account ||= self.accounts.where(:ignored => false).order('id desc').first
    end

    def can_be_approved?
      eid = self.email_identity
      # return false unless self.account
      return false unless eid and eid.email # and eid.verified
      pid = self.phone_identity
      return false unless pid and pid.phone # and pid.verified
      return false unless eid.verified or pid.verified
      return true
    end

    def approve
      result = {}
      logger.info "Approve user ##{id} #{display_name}"
      # if self.account_status == 'approved' or self.account_status == 'created'
      #   logger.error "User ##{id} #{display_name} is already approved or created"
      #   return
      # end
      eid = self.email_identity
      if !eid or eid.confirmation_code.blank? or eid.email.blank?
        logger.error "!!! Signup approve error: user's email not found [##{self.id}]"
        return
      end
      begin
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
        if Rails.env.production?
          sg = SendGrid::API.new(api_key: ENV['SDC_SENDGRID_API_KEY'])        
          response = sg.client.mail._("send").post(request_body: data)
          if response.status_code.to_i >= 300
            logger.error 'SendGrid error', response.inspect
            result[:error] = response
            return result
          else
            logger.info "Sent signup approval email to #{eid.email} with status code #{response.status_code}"
          end
        end

        self.update_attribute(:account_status, 'approved')
        result[:sucess] = true
        return result
      rescue => e
        logger.error "Caught SendGrid error: #{e.message}"
        logger.error e.backtrace.join("\n")
        result[:error] = e.message
      end
      return result
    end

    def reject!
      self.update_attribute(:account_status, 'rejected')
    end

    def putonhold!
      self.update_attribute(:account_status, 'onhold')
    end

end
