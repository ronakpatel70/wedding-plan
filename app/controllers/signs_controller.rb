class SignsController < BaseController
  before_action :set_sign, only: [:show, :edit, :update, :destroy]
  before_action :set_show, only: [:index, :new, :create]

  # GET /signs
  # GET /signs.json
  def index
    @signs = Sign.all.join_vendors.join_booths(@current_show.id).order('id DESC')
    @needed = @current_show.booths.approved.with_sign.where(sign_id: nil).pluck(:vendor_id)
  end

  # GET /signs/1
  # GET /signs/1.json
  def show
  end

  # GET /signs/new
  def new
    @sign = Sign.new
  end

  # GET /signs/1/edit
  def edit
  end

  # POST /signs
  # POST /signs.json
  def create
    params[:sign][:vendor_ids].map! { |i| i.to_i }.reject! { |i| i <= 0 }
    @sign = Sign.new(sign_params)

    respond_to do |format|
      if @sign.save
        format.html { redirect_to :signs, notice: 'Sign was successfully created.' }
        format.json { render :show, status: :created, location: @sign }
      else
        format.html { render :new }
        format.json { render json: @sign.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /signs/1
  # PATCH/PUT /signs/1.json
  def update
    params[:sign][:vendor_ids].map! { |i| i.to_i }.reject! { |i| i <= 0 }
    respond_to do |format|
      if @sign.update(sign_params)
        format.html { redirect_to :signs, notice: 'Sign was successfully updated.' }
        format.json { render :show, status: :ok, location: @sign }
      else
        format.html { render :show }
        format.json { render json: @sign.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /signs/1
  # DELETE /signs/1.json
  def destroy
    @sign.destroy
    respond_to do |format|
      format.html { redirect_to :signs, flash: { alert: 'Sign was destroyed.' } }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_sign
      @sign = Sign.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def sign_params
      params.require(:sign).permit(:id, :front, :back, :missing, :informational, :vendor_ids => [])
    end
end
