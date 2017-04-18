class FormBuilder < ActionView::Helpers::FormBuilder
  include ActionView::Helpers::NumberHelper
  include ActionView::Helpers::TagHelper
  include ActionView::Helpers::UrlHelper

  def switch(method)
    content_tag(:div, check_box(method) + label(method), class: "switch")
  end

  def text_group(method, options = {})
    float_class = "half clearfix" if options.delete(:float)
    content = label(method, options.delete(:label)) + text_field(method, options)
    form_group(content, float_class)
  end

  def password_group(method, options = {})
    options[:placeholder] ||= "Minimum 8 characters"
    content = label(method, options.delete(:label)) + password_field(method, options)
    form_group(content)
  end

  def phone_group(method, options = {})
    options[:value] ||= number_to_phone(object[method])
    content = label(method, options.delete(:label)) + telephone_field(method, options)
    form_group(content)
  end

  def text_area_group(method, options = {})
    content = label(method, options.delete(:label)) + text_area(method, options)
    form_group(content)
  end

  def select_group(method, tags = {}, options = {}, html_options = {})
    content = label(method, options.delete(:label)) + select(method, tags, options, html_options)
    form_group(content)
  end

  def date_group(method, options = {})
    options[:with_css_classes] = true
    content = label(method) + date_select(method, options)
    form_group(content)
  end

  def switch_group(method, options = {})
    float_class = "half clearfix" if options.delete(:float)
    content = label(method, options.delete(:label)) + switch(method)
    form_group(content, float_class)
  end

  def time_group(method, options = {})
    options[:with_css_classes] = true
    float_class = "half clearfix" if options.delete(:float)
    content = label(method) + time_select(method, options)
    form_group(content, float_class)
  end

  def number_group(method, options = {})
    float_class = "half clearfix" if options.delete(:float)
    content = label(method, options.delete(:label)) + number_field(method, options)
    form_group(content, float_class)
  end

  def text_col(method, width, options = {})
    content = label(method, options.delete(:label)) + text_field(method, options)
    form_col content, width, options.delete(:col)
  end

  def number_col(method, width, options = {})
    content = label(method, options.delete(:label)) + number_field(method, options)
    form_col content, width, options.delete(:col)
  end

  def password_col(method, width, options = {})
    options[:placeholder] ||= "Minimum 8 characters"
    content = label(method, options.delete(:label)) + password_field(method, options)
    form_col content, width, options.delete(:col)
  end

  def phone_col(method, width, options = {})
    options[:value] ||= number_to_phone(object[method])
    content = label(method, options.delete(:label)) + telephone_field(method, options)
    form_col content, width, options.delete(:col)
  end

  def select_col(method, width, tags = {}, options = {}, html_options = {})
    content = label(method, options.delete(:label)) + select(method, tags, options, html_options)
    form_col content, width, options.delete(:col)
  end

  def date_col(method, width, options = {})
    options[:with_css_classes] = true
    content = label(method) + date_select(method, options)
    form_col content, width
  end

  def editor_col(method, width, options = {})
    form_col @template.render("editor", form: self, method: method, object: object.class.to_s.underscore), width, "markdown-editor"
  end

  def file_col(method, width, options = {})
    content = label(method) + file_field(method, options)
    form_col content, width, options.delete(:col)
  end

  def switch_col(method, width, options = {})
    content = label(method, options.delete(:label)) + switch(method)
    form_col content, width, options.delete(:col)
  end

  def time_col(method, width, options = {})
    content = label(method) + time_select(method, with_css_classes: true)
    form_col content, width, options.delete(:col)
  end

  def text_area_col(method, width, options = {})
    content = label(method, options.delete(:label)) + text_area(method, options)
    form_col content, width, options.delete(:col)
  end

  private
    def form_col(content, width, classes = "")
      content_tag :div, content, class: "small-#{width} columns #{classes}"
    end

    def form_group(content, classes = "")
      content_tag :div, content, class: "form-group #{classes}"
    end
end
