require 'sendgrid-ruby'

class Arec < ActiveRecord::Base
  belongs_to :user

  scope :by_email, -> { where(:provider => 'email') }

  def approved?
    self.status == 'confirmed' && self.validation_code
  end

  def approve!
    logger.info "Approve account recovery ##{id} #{contact_email}"

    code = SecureRandom.hex(10)
    self.update_attributes(status: 'confirmed', validation_code: code)

    data = JSON.parse(%Q{{
      "personalizations": [
        {
          "to": [
            {
              "email": "#{self.contact_email}"
            }
          ],
          "substitutions": {
            "confirmation_code": "#{code}"
          },
          "subject": "Your Steemit account recovery request has been approved"
        }
      ],
      "from": {
        "email": "#{ENV['SDC_SENDGRID_FROM']}"
      },
      "template_id": "7d7f0217-2e45-4168-9cb5-ca90d4a7591a"
    }})
    sg = SendGrid::API.new(api_key: ENV['SDC_SENDGRID_API_KEY'])
    response = sg.client.mail._("send").post(request_body: data)
    logger.info "Sent arec approved email to #{self.contact_email} with status code #{response.status_code}"
    if response.status_code.to_i >= 300
      logger.error response.inspect
    end

  end

  def email_match?
    account = Account.where(name: self.account_name).first
    return false unless account
    eid = account.user.email_identity
    return (eid and eid.email and eid.email == self.contact_email)
  end

  def account
    Account.where(name: self.account_name).first
  end

end
