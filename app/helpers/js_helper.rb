module JsHelper
  def set_var(name, value)
    "<script>window['#{name}'] = '#{value}'</script>".html_safe
  end
end
