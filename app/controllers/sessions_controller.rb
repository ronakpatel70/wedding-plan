class SessionsController < BaseController
  skip_before_action :authenticate, only: [:new, :create, :destroy]
  skip_before_action :verify_authenticity_token, only: [:create, :destroy]

  # GET /
  def index
    render layout: "base"
  end

  # GET /login
  def new
    return redirect_to(:root) if session[:admin_id] && session[:expires]

    if params.has_key?(:token) && Rails.env.development?
      verifier = ActiveSupport::MessageVerifier.new(Rails.application.secrets[:secret_key_base])
      user = User.admins.find(verifier.verify(params[:token]))
      session[:admin_id] = user.id
      session[:expires] = 30.days.from_now
      return redirect_to(:root)
    end
  end

  # POST /login
  def create
    email = current_user ? current_user.email : session_params[:email].downcase
    user = User.admins.where.not(password_digest: nil).find_by(email: email)
    if user and user.authenticate(session_params[:password])
      session[:admin_id] = user.id
      session[:expires] = 72.hours.from_now
      redirect_to(session[:redirect] || root_path)
    else
      msg = if user && user.locked?
        min = ((user.locked_until - DateTime.now) / 60).ceil
        "This account has been locked for #{min} #{'minute'.pluralize(min)}."
      else
        "Incorrect email or password."
      end
      redirect_to :new_session, alert: msg
    end
  end

  # DELETE /login
  def destroy
    reset_session
    redirect_to :new_session
  end

  private
    def session_params
      params.require(:session).permit(:email, :password)
    end
end
