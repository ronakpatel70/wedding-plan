class FeesController < BaseController
  before_action :set_fee, only: [:show, :edit, :update, :destroy]

  # GET /fees/new
  def new
    @fee = Fee.new
    @fee.booth = Booth.find(params[:booth_id])
  end

  # POST /fees
  # POST /fees.json
  def create
    params[:fee][:amount].gsub!(/[$,]/, '')
    params[:fee][:amount] = (params[:fee][:amount].to_f * 100).to_i

    @fee = Fee.new(fee_params)
    @fee.booth = Booth.find(params[:booth_id])

    respond_to do |format|
      if @fee.save
        format.html { redirect_to @fee.booth, notice: 'Fee was successfully created.' }
        format.json { render :show, status: :created, location: @fee }
      else
        format.html { render :new }
        format.json { render json: @fee.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /fees/1
  # DELETE /fees/1.json
  def destroy
    @fee.destroy
    respond_to do |format|
      format.html { redirect_to @fee.booth, flash: { warning: 'Fee was deleted.' } }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_fee
      @fee = Fee.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def fee_params
      params.require(:fee).permit(:description, :amount)
    end
end
