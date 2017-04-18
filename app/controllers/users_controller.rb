class UsersController < BaseController
    include Pdf

  before_action :set_user, only: [:show, :edit, :update, :destroy, :login]
  before_action :set_show, only: [:index, :new], if: Proc.new { params.has_key?(:show_id) }

  # GET /shows/1/attendees
  # GET /shows/1/attendees.pdf
  def index
    @users = @current_show.users.includes(:events)
    @tickets = @current_show.tickets.paid.group(:user_id).sum(:quantity)
    @passes = @current_show.tickets.free.group(:user_id).sum(:quantity)
    @prizes = @current_show.packages.where.not(winner: nil).group(:winner_id).count

    respond_to do |format|
      format.html { @users = @users.reverse }
      format.pdf do
        booths_with_labels = @current_show.booths.approved.with_add_on('labels')
        printable_users = @users.where.not(address: nil).order(:first_name, :last_name)
        pdf = mailing_labels_pdf(booths_with_labels, printable_users)
        send_data(pdf.render, disposition: 'inline', filename: 'mailing_labels.pdf')
      end
    end
  end

  # GET /users/1
  # GET /users/1.json
  def show
    @user.address ||= Address.new
    @user.events.new if @user.events.empty?

    respond_to do |format|
      format.html
      format.json
      format.pdf do
        @user.shows << Show.current unless @user.shows.exists?(id: Show.current.id)
        event = @user.events.first
        pdf = prize_labels_pdf(@user, event, true, Show.current.packages.highlighted.count)
        send_data(pdf.render, disposition: 'inline', filename: 'prize_labels.pdf')
      end
    end
  end

  # GET /users/new
  def new
    @user = User.new
    @user.address = Address.new
    @user.events.new
    @show = Show.find(params[:show_id]) if params.has_key?(:show_id)
    @vendor = Vendor.find(params[:vendor_id]) if params.has_key?(:vendor_id)
    flash[:redirect] = params[:redirect] if params.has_key?(:redirect)
  end

  # POST /users
  # POST /users.json
  def create
    @user = User.new(user_params)

    if roles = params[:user][:roles]
      roles.map { |r| r.downcase }.each do |role|
        unless role.empty?
           @user.roles << Role.new(type: role)

          if role == "admin"
            respond_to do |format|
              if @user.save
                format.html { redirect_to (flash[:redirect] || :attendees), notice: 'User was successfully created.' }
                format.json { render :show, status: :created, location: @user }
              else
                format.html { render :new }
                format.json { render json: @user.errors, status: :unprocessable_entity }
              end
            end
          end

          if role == "staff"
            redirect_to get_staff_list_path
          end

        end
      end
    end
  end

  # PATCH/PUT /users/1
  # PATCH/PUT /users/1.json
  def update
    roles = params[:user].delete(:roles)
    if roles.present?
      roles.map! { |r| r.downcase }
      ['admin', 'staff'].each do |type|
        role = @user.roles.find_by(type: Role.types[type])
        if role && !roles.include?(type)
          role.destroy
        elsif !role && roles.include?(type)
           @user.roles << Role.new(type: type)
        end
      end
    end

    respond_to do |format|
      if @user.update(user_params)
        format.html do
          if request.referer == settings_url
            redirect_to :settings, notice: 'Saved.'
          else
            redirect_to  :attendees, notice: 'User was successfully updated.'
          end
        end
        format.json { render :show, status: :ok, location: @user }
      else
        format.html { redirect_to :back, alert: @user.errors.full_messages.first }
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /users/1
  # DELETE /users/1.json
  def destroy
    if @user.destroy
      redirect_to :attendees, flash: { warning: 'User was deleted.' }
    else
      msg = if @user.errors.present?
        @user.errors.full_messages.join(".\n") + "."
      else "User could not be deleted." end
      redirect_to @user, alert: msg
    end
  end

  # GET /users/1/login
  def login
    message = { user: @user.id, expires: (Time.now + 1.minute).to_i }
    verifier = ActiveSupport::MessageVerifier.new(Rails.application.secrets[:public_site_secret_key])
    token = CGI.escape(verifier.generate(message))
    redirect_to "//weddingexpo.co/account/login?token=#{token}"
  end


  def user_email

  end

  def sync_cm_task
    begin
      # Call rake task to sync
      %x[rake cm:sync]
      flash[:notice] = "Sync Completed"
    rescue Exception => e
      flash[:notice] = "Error occured while sync. #{e}"
    end
    redirect_to user_email_path
  end

  def get_staff_list

    @staffs = User.staff

    respond_to do |format|
      format.html { @staffs = @staffs.reverse }
    end

  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_user
      @user = User.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def user_params
      params.require(:user).permit(:first_name, :last_name, :email, :phone, :password, :event_role, :receive_email,
        :receive_sms, :show_ids => [], :vendor_ids => [], :address_attributes => [:street, :city, :state, :zip],
        :events_attributes => [:id, :date])
    end
end
