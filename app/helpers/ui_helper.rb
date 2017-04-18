module UiHelper
  def action_list(*actions)
    title = @html_title || content_for(:title)
    obj = title.downcase.singularize
    robj = obj.gsub(' ', '_')
    actions.map do |action|
      link = case action
        when :map then link_to(icon(:map), "/map", class: 'icon', title: "Open map", target: "_blank")
        when :new then link_to(icon(:document_plus), "new_#{robj}".to_sym, class: 'icon', title: "New #{obj}")
        when :new_user then link_to(icon(:user_add), "new_#{robj}".to_sym, class: 'icon', title: "New #{obj}")
        when :new_group then link_to(icon(:group_plus), "new_#{robj}".to_sym, class: 'icon', title: "New #{obj}")
        when :download then link_to(icon(:file_type_table), "#{request.path}.csv", class: 'icon', title: "Download CSV")
        when :link then link_to(icon(:link), "#{request.path}/link", class: 'icon', title: "Generate redemption link")
      end
      content_tag(:li, link, class: 'action inline')
    end.join.html_safe
  end

  def alert_box(text, type, close = true)
    inner = text
    if close
      inner += content_tag(:a, '&times;'.html_safe, class: 'close', href: '#')
    end
    row = content_tag(:div, content_tag(:div, inner.html_safe, class: 'small-12 columns'), class: 'row')
    content_tag :div, row, class: "alert-box grid #{type}", data: {alert: ''}
  end

  def badge(text, classes, options = {})
    options[:class] = "label #{classes}"
    content_tag :span, text, options
  end

  def dropdown_button(button_text, id, links, options = {})
    if options[:disabled]
      return content_tag(:button, button_text, class: 'tiny radius button dropdown disabled')
    else
      btn = content_tag(:button, button_text, class: 'tiny radius button dropdown', data: { dropdown: id })
      lis = links.map do |l|
        l[2] ? content_tag(:li, link_to(l[0], l[1])) : content_tag(:li, content_tag(:span, l[0]), class: 'disabled')
      end
      ul = content_tag(:ul, lis.join.html_safe, id: id, class: 'f-dropdown right-arrow', 'data-dropdown-content' => '')
      return btn + ul
    end
  end

  def icon(symbol, attrs = {})
    svg = File.read("lib/assets/icons/#{symbol}.svg").html_safe
    content_tag(:i, svg, attrs)
  end

  def nav_link(text, route, sub_links = {}, options = {})
    a = link_to(text, route, options)

    sub_links.each do |sub_text, sub_route|
      sub_path = send(:"#{sub_route}_path")
      path_after_show = request.path.split(/\/shows\/[0-9]+/).last
      if !@current_show && request.path.start_with?(sub_path) ||
        path_after_show && path_after_show.start_with?(sub_path.split(/\/shows\/[0-9]+/).last)
          content_for(:sub_nav, sub_nav(sub_links, sub_text))
          return content_tag(:li, a, class: 'active')
      end
    end

    content_tag :li, a
  end

  def set_container(size)
    @layout_container = "container-#{size}"
  end

  def set_title(page, html = page)
    @page_title = page
    @html_title = html
  end

  def show_errors_for(object)
    content_for(:errors, object.errors.full_messages.map { |m| "#{m}."}.join('<br>').html_safe)
  end

  def side_nav(base, links = {})
    lis = links.map do |name, path|
      fp = [base, path].compact.join('/')
      tag = request.path == fp ? content_tag(:strong, name) : link_to(name, fp)
      content_tag(:li, tag, class: 'aside-link')
    end
    content_tag(:ul, lis.join.html_safe)
  end

  def sub_nav(links, active_link_text)
    dds = links.map do |text, path|
      a = link_to(text, path)
      active_class = 'active' if text == active_link_text
      content_tag(:dd, a, class: active_class)
    end

    if @current_show
      shows = Show.fresh.includes(:location).map do |s|
        ["#{s.date.to_s(:semiformal)} - #{s.location}", request.path.sub(/[0-9]+/, s.id.to_s), s != @current_show]
      end
      picker = content_tag(:dd, dropdown_button(@current_show.date.to_s(:semiformal), 'nav-show-picker', shows), class: 'right')
      dds.append(picker)
    elsif @inactive_show
      picker = content_tag(:dd, dropdown_button(@inactive_show.date.to_s(:semiformal), 'nav-show-picker', [], disabled: true), class: 'right')
      dds.append(picker)
    end

    content_tag(:dl, dds.join.html_safe, class: 'sub-nav')
  end
end
