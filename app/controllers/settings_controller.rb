class SettingsController < BaseController
  skip_before_action :verify_authenticity_token, only: [:preview]

  def index
    @user = current_user
  end

  # Renders Markdown preview
  def preview
    output = Markdown.render(request.body.read)
    render html: output.html_safe, layout: false
  end
end
