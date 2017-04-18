class PrizesController < BaseController
  before_action :set_prize, only: [:show, :edit, :update, :destroy]
  before_action :set_show, only: [:index, :new, :create]

  # GET /prizes
  # GET /prizes.json
  def index
    @prizes = @current_show.prizes.all.order('updated_at DESC')
  end

  # GET /prizes/1
  # GET /prizes/1.json
  def show
  end

  # GET /prizes/new
  def new
    @prize = Prize.new
  end

  # GET /prizes/1/edit
  def edit
  end

  # POST /prizes
  # POST /prizes.json
  def create
    params[:prize][:value] = params[:prize][:value].to_i * 100
    @prize = Prize.new(prize_params)
    @prize.show = @current_show

    respond_to do |format|
      if @prize.save
        format.html { redirect_to :prizes, notice: 'Prize was successfully created.' }
        format.json { render :show, status: :created, location: @prize }
      else
        format.html { render :new }
        format.json { render json: @prize.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /prizes/1
  # PATCH/PUT /prizes/1.json
  def update
    params[:prize][:value] = params[:prize][:value].to_i * 100
    respond_to do |format|
      if @prize.update(prize_params)
        format.html { redirect_to :prizes, notice: 'Prize was successfully updated.' }
        format.json { render :show, status: :ok, location: @prize }
      else
        format.html { render :show }
        format.json { render json: @prize.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /prizes/1
  # DELETE /prizes/1.json
  def destroy
    @prize.destroy
    respond_to do |format|
      format.html { redirect_to prizes_url, flash: { warning: 'Prize was deleted.' } }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_prize
      @prize = Prize.find(params[:id])
      @inactive_show = @prize.show
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def prize_params
      params.require(:prize).permit(:vendor_id, :name, :quantity, :value, :rules, :type, :status, :is_manned)
    end
end
