class BaseController < ActionController::Base
  protect_from_forgery with: :null_session

  before_action :check_utf8
  before_action :authenticate

  helper_method :current_user
  helper_method :current_show_id

  def current_user
    if request.authorization
      @current_user ||= authenticate_with_http_token { |t, o| Token.find(t).user }
    else
      @current_user ||= User.admins.find_by(id: session[:admin_id])
    end
  end

  def current_show_id
    if params.has_key?(:show_id)
      session[:show_id] = params[:show_id]
    else
      session[:show_id] ||= Show.next.id
    end
  end

  # Generate route helpers for routes that include a show id.
  ['attendee', 'booth', 'job_application', 'pass', 'package', 'prize', 'shift', 'sign', 'ticket'].each do |resource|
    ['path', 'url'].each do |suffix|
      helper_method(name = "#{resource.pluralize}_#{suffix}")
      define_method(name) { |format = nil| send("show_#{__method__}", show_id: current_show_id, format: format) }
      helper_method(name = "new_#{resource}_#{suffix}")
      define_method(name) { |format = nil| send(__method__.to_s.insert(4, 'show_'), show_id: current_show_id, format: format) }
    end
  end

  private
    # TODO: add unit test
    def check_utf8
      if params.has_key? 'utf8' and params['utf8'] != '✓'
        render text: 'Bad Request', status: 400
      end
    end

    def authenticate
      if current_user == nil
        reset_session
        session[:redirect] = request.fullpath
        redirect_to :new_session
      elsif session[:expires] && session[:expires] <= Time.now
        session[:expires] = nil
        redirect_to :new_session
      end
    end

    def set_show
      @current_show = Show.find(current_show_id)
    end
end
