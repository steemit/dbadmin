class UserAttributes < ActiveRecord::Base
  self.table_name = 'user_attributes'
  scope :referer_only, -> {where type_of: 'referer'}

  belongs_to :user
end