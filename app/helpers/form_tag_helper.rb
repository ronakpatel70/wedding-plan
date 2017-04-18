module FormTagHelper
  # Two-dimensional array of booth sizes for use in selects, e.g. [["3x6", "3x6 Starter ($600)"], ...]
  def booth_sizes
    Config.booths.map { |size, attrs| ["#{size} #{attrs[:title]} ($#{attrs[:price]/100})", size] }
  end

  # Button-style link that alerts the user before deleting the resource
  def delete_link(object, destructive = false)
    return nil if object.new_record?
    object_name = object.class.to_s.underscore.humanize.downcase
    text = "Delete #{object_name}"
    if destructive
      modal = {
        title: "Listen up!",
        alert: alert_box("This is an <strong>EXTREMELY DESTRUCTIVE</strong> action.", "warning", false),
        body: "You are about to permanently delete this #{object_name} and all associated objects. This cannot be undone.",
        button: link_to("I understand, delete this #{object_name}", object, class: "button alert radius", method: "delete")
      }
      link_to(text, object, class: "button-link alert modal-trigger", data: {modal: modal})
    else
      data = { method: "delete", confirm: "Are you sure?" }
      link_to(text, object, class: "button-link alert", data: data)
    end
  end

  # Column containing a label and div for use in a form
  def static_col(name, value, width = 12, options = {})
    content = content_tag(:label, name) + content_tag(:p, value)
    content_tag :div, content, class: "small-#{width} columns #{options[:col]}"
  end

  # Div containing a label and div for use in a form
  def static_group(name, value, options = {})
    div_class = "half clearfix" if options.delete(:float)
    content = content_tag(:label, name) + content_tag(:p, value, options)
    content_tag :div, content, class: div_class
  end
end
