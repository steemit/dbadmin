class WebEvent < ActiveRecord::Base
  # default_scope { where(first_visit: true, status: 200, event_type: 'page_load') }
  scope :visit, -> { where(first_visit: true, status: 200, event_type: 'page_load') }

end
