require 'sendgrid-ruby'

class Arec < ActiveRecord::Base
  belongs_to :user

  scope :by_email, -> { where(:provider => 'email') }

  def approved?
    self.status == 'confirmed' && self.validation_code
  end

  def approve!(current_admin_user = nil)
    logger.info "Approve account recovery ##{id} #{contact_email}"

    ActiveAdmin::Comment.create(
      resource_id: self.id,
      resource_type: 'Arec',
      namespace: 'admin',
      body: "approved by #{current_admin_user.email}",
      author_id: current_admin_user.id,
      author_type: 'AdminUser'
    )

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
    if Rails.env.production?
      sg = SendGrid::API.new(api_key: ENV['SDC_SENDGRID_API_KEY'])
      response = sg.client.mail._("send").post(request_body: data)
      logger.info "Sent arec approved email to #{self.contact_email} with status code #{response.status_code}"
      if response.status_code.to_i >= 300
        logger.error response.inspect
      end
    end
  end

  def email_match?
    return false unless account
    return false unless account.user
    return account.user.contains_email_identity?(self.contact_email)
  end

  def account
    return @account ||= Account.where(name: self.account_name).first
  end

  def was_recently_recovered
    return false unless self.account_name
    rec = Arec.where("id<>#{self.id} and account_name='#{self.account_name}' and request_submitted_at >= (NOW() - INTERVAL 30 DAY)").first
    puts "was_recently_recovered:", rec.inspect
    return !!rec
  end

end
