module ApplicationHelper
  def text_with_checkmark(text, title, checkmark)
    if checkmark
      icon = '&#10004;'.html_safe
      color = '#0c0'
      checkmark = content_tag(:span, icon, :style => "color: #{color}; cursor: default;", title: title)
      return text ? "#{text} #{checkmark}".html_safe : checkmark
    else
      text
    end
  end
end
