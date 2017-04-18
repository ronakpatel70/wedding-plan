class JobApplicationsController < BaseController
  before_action :set_job_application, only: [:show, :edit, :update, :destroy]
  before_action :set_show, only: [:index, :schedule, :new, :create]

  # GET /job_applications
  # GET /job_applications.json
  def index
    @job_apps = @current_show.job_applications.eager_load(:user).order('users.first_name ASC, users.last_name ASC')
  end

  # GET /job_applications/1
  # GET /job_applications/1.json
  def show
  end

  # GET /job_applications/new
  def new
    @job_app = JobApplication.new
  end

  # POST /job_applications
  # POST /job_applications.json
  def create
    @job_app = JobApplication.new(job_application_params)
    @job_app.show_id = @current_show.id

    respond_to do |format|
      if @job_app.save
        format.html { redirect_to :job_applications, notice: 'Job application was successfully created.' }
        format.json { render :show, status: :created, location: @job_app }
      else
        format.html { render :new }
        format.json { render json: @job_app.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /job_applications/1
  # PATCH/PUT /job_applications/1.json
  def update
    respond_to do |format|
      if @job_app.update(job_application_params)
        format.html { redirect_to :job_applications, notice: 'Job application was successfully updated.' }
        format.json { render :show, status: :ok, location: @job_app }
      else
        format.html { render :show }
        format.json { render json: @job_app.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /job_applications/1
  # DELETE /job_applications/1.json
  def destroy
    @job_app.destroy
    respond_to do |format|
      format.html { redirect_to :job_applications, flash: { warning: 'Job application was destroyed.' } }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_job_application
      @job_app = JobApplication.find(params[:id])
      @inactive_show = @job_app.show
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def job_application_params
      params.require(:job_application).permit(:user_id, :status, :requests, :requested_start, :requested_end)
    end
end
