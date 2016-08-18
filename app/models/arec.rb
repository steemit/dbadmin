class Arec < ActiveRecord::Base
  belongs_to :user

  scope :by_email, -> { where(:provider => 'email') }

  def approved?
    self.status == 'confirmed' && self.validation_code
  end

  def approve!
    code = SecureRandom.hex(10)
    self.update_attributes(status: 'confirmed', validation_code: code)
  end

end
