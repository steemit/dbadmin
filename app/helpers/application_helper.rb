module ApplicationHelper
  def text_with_checkmark(text, title, checkmark)
    if checkmark
      icon = '&#10004;'.html_safe
      color = '#0c0'
      checkmark = content_tag(:span, icon, :style => "color: #{color}; cursor: default;", title: title)
      return text ? "#{text} #{checkmark}".html_safe : checkmark.html_safe
    else
      if text.present?
        text.html_safe
      end
    end
  end


  def render_account_status_tag(u, context)
    return '-' unless u
    color = case u.account_status
    when 'approved'
      :ok
    when 'waiting'
      :orange
    when 'rejected'
      :red
    when 'created'
      :yes
    else
      :no
    end
    context.status_tag(u.account_status, color)
  end

end
