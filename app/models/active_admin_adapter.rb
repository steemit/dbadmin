class ActiveAdminAdapter < ActiveAdmin::AuthorizationAdapter
  def authorized?(action, subject = nil)
    !(action == ActiveAdmin::Auth::DESTROY && subject.is_a?(ActiveAdmin::Comment))
  end
end
