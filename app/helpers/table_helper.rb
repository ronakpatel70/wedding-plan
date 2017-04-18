module TableHelper
  # Renders a row representing a collection of folded rows that can be expanded
  def fold(text, count, options = {})
    if count > 0
      options[:class] ||= "warning"
      options[:colspan] ||= 10
      td = content_tag(:td, pluralize(count, text), options)
      return content_tag(:tr, td, class: ("fold " + options[:class]))
    end
  end

  # Renders a collection of dropdown buttons containing links to filter a list
  # view. `groups` should be a hash mapping parameter names to arrays of values.
  def filter_buttons(base_path, filters = {})
    buttons = filters.map do |filter, values|
      btn_color = @filters.has_key?(filter) ? 'primary' : 'secondary'
      btn = content_tag(:button, filter.to_s.humanize,
        class: "tiny radius button dropdown #{btn_color}", 'data-dropdown' => filter)

      list_items = values.map do |varr|
        val, str = *varr
        str ||= varr
        if @filters[filter] == val.to_s
          query_params = @filters.reject { |f, k| f == filter.to_s }
          link = link_to(str.to_s.humanize + ' - Clear', query_params, class: 'canceled')
        else
          query_params = @filters.merge(filter => val)
          link = link_to(str.to_s.humanize, send(base_path, query_params))
        end
        content_tag(:li, link)
      end.join.html_safe

      ul = content_tag(:ul, list_items, class: 'f-dropdown right-arrow', id: filter,
        data: {dropdown_content: ''})
      content_tag(:li, btn + ul, class: 'filter left')
    end.join.html_safe

    content_tag(:ul, buttons)
  end
end
