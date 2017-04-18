class PackagesController < BaseController
  before_action :set_package, only: [:show, :edit, :update, :destroy]
  before_action :set_show, only: [:index, :new, :create, :vendors]

  # GET /shows/1/packages
  # GET /shows/1/packages.json
  def index
    @packages = @current_show.packages.preload(:winner, :prizes => :vendor).order(:ribbon)
  end

  # GET /shows/1/packages/vendors.csv
  def vendors
    @vendors = Vendor.select("vendors.*, COUNT(packages.*) as winners").joins(:prizes => :packages).
      where("prizes.status = 1 AND prizes.show_id = ? AND packages.winner_id IS NOT NULL", current_show_id).group("vendors.id")
  end

  # GET /packages/1
  # GET /packages/1.json
  def show
  end

  # GET /shows/1/packages/new
  def new
    @package = Package.new
    @package.show = @current_show
  end

  # GET /packages/1/edit
  def edit
  end

  # POST /shows/1/packages
  # POST /shows/1/packages.json
  def create
    @package = Package.new(package_params)
    @package.show = @current_show

    respond_to do |format|
      if @package.save
        format.html { redirect_to :packages, notice: 'Package was successfully created.' }
        format.json { render :show, status: :created, location: @package }
      else
        format.html { render :new }
        format.json { render json: @package.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /packages/1
  # PATCH/PUT /packages/1.json
  def update
    respond_to do |format|
      if @package.update(package_params)
        format.html { redirect_to :packages, notice: 'Package was successfully updated.' }
        format.json { render :show, status: :ok, location: @package }
      else
        format.html { render :show }
        format.json { render json: @package.errors.full_messages, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /packages/1
  # DELETE /packages/1.json
  def destroy
    @package.destroy
    respond_to do |format|
      format.html { redirect_to :packages, flash: { warning: 'Package was deleted.' } }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_package
      @package = Package.find(params[:id])
      @inactive_show = @package.show
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def package_params
      params.require(:package).permit(:name, :type, :rules, :winner_id, :prize_ids => [])
    end
end
