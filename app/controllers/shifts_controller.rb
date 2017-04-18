class ShiftsController < BaseController
  before_action :set_shift, only: [:show, :edit, :update, :destroy]
  before_action :set_show, only: [:index, :schedule, :timesheet, :new, :create]

  # GET /shifts
  # GET /shifts.json
  def index
    @users = User.staff.joins(:job_applications).where(job_applications: {show: @current_show, status: 1}).order(:first_name, :last_name)
    @positions = Position.active.order(:name)
    @shifts = Hash[@positions.map { |pos| [pos.id, []] }]
    @current_show.shifts.includes(:user).each { |s| @shifts[s.position_id] << s }
    start = @current_show.start
    @times = [(start - 270.minutes),
      (start - 90.minutes),
      (start + 90.minutes),
      (start + 270.minutes)]
  end

  # GET /shifts/schedule
  # GET /shifts/schedule.json
  def schedule
    @users = User.includes(:shifts => :position).where(shifts: {show: @current_show}).order("users.first_name, users.last_name, shifts.updated_at")
    @start = @current_show.start - 4.5.hours
    @end = @current_show.start + 7.5.hours
    @shift_data = Hash[@users.map { |u| u.shifts }.flatten.map { |s| [s.id, { url: shift_path(s, :json), start_time: s.start_time, end_time: s.end_time }] }]

    respond_to do |format|
      format.html
      format.json { render 'schedule' }
    end
  end

  # GET /shifts/timesheet
  def timesheet
    @users = User.staff.joins(:job_applications).eager_load(:shifts).
      where(job_applications: {show: @current_show, status: 1}, shifts: {show: @current_show}).
      order('users.first_name, users.last_name, shifts.start_time')
    transfers = Transfer.where('status NOT IN (3, 4) AND created_at > ?', @current_show.start.beginning_of_day)
    @user_totals = {}
    transfers.each do |t|
      @user_totals[t.user_id] = 0 unless @user_totals.has_key?(t.user_id)
      @user_totals[t.user_id] += t.amount
    end
  end

  # GET /shifts/1
  # GET /shifts/1.json
  def show
  end

  # POST /shifts
  # POST /shifts.json
  def create
    @shift = Shift.new(shift_params)
    @shift.show = @current_show

    respond_to do |format|
      if @shift.save
        format.html { redirect_to :shifts, notice: 'Shift was successfully created.' }
        format.json { render :show, status: :created, location: @shift }
      else
        format.html { render :new }
        format.json { render json: @shift.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /shifts/1
  # PATCH/PUT /shifts/1.json
  def update
    [:in_time, :out_time].each do |i|
      if shift_params[i] =~ /^[0-9]{1,2}:[0-9]{2}[ap]m$/
        params[:shift][i] = @shift.start_time.to_date.to_s(:db) + " " + shift_params[i]
        puts params[:shift][i]
      end
    end

    respond_to do |format|
      if @shift.update(shift_params)
        format.html { redirect_to :shifts, notice: 'Shift was successfully updated.' }
        format.json { render :show, status: :ok, location: @shift }
      else
        format.html { render :edit }
        format.json { render json: @shift.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /shifts/1
  # DELETE /shifts/1.json
  def destroy
    @shift.destroy
    respond_to do |format|
      format.html { redirect_to :shifts, notice: 'Shift was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_shift
      @shift = Shift.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def shift_params
      params.require(:shift).permit(:user_id, :position_id, :start_time, :end_time, :in_time, :out_time, :status)
    end
end
