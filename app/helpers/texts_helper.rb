module TextsHelper
  def texter_display(texter, phone)
    return "--" if phone == "7078760001"
    link = texter ? link_to(texter, texter) : "Unknown"
    return "#{link} <#{phone}>".html_safe
  end
end
