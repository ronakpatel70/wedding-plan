class Markdown
  require 'redcarpet'

  RENDERER = Redcarpet::Render::HTML.new(filter_html: true)
  MD = Redcarpet::Markdown.new(RENDERER, no_intra_emphasis: true, autolink: true,
    fenced_code_blocks: true, disable_indented_code_blocks: true)

  def self.render(input)
    MD.render(input)
  end
end
