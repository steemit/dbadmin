class User < ActiveRecord::Base
    has_many :accounts, dependent: :destroy
    has_many :identities, dependent: :destroy

    scope :waiting_list, -> { where(:waiting_list => 1) }

end
