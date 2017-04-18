class TransfersController < BaseController
  before_action :set_transfer, only: [:show, :edit, :update, :destroy]

  # GET /transfers
  # GET /transfers.json
  def index
    @transfers = Transfer.all.order('created_at DESC')
  end

  # GET /transfers/new
  def new
    @transfer = Transfer.new
    @transfer.user_id = params[:user_id]
    @transfer.amount = @transfer.user.shifts.inject(0) { |sum, shift| sum += shift.time_worked }.round(1) * 1200
  end

  # POST /transfers
  # POST /transfers.json
  def create
    params[:transfer][:amount] = transfer_params[:amount].sub('$', '').to_f * 100
    @transfer = Transfer.new(transfer_params)

    respond_to do |format|
      if @transfer.save
        format.html { redirect_to timesheet_show_shifts_url(params[:show_id]), notice: "Initiated transfer of #{@transfer.amount / 100.0} USD to #{@transfer.user}." }
        format.json { render :show, status: :created, location: @transfer }
      else
        format.html { render :new }
        format.json { render json: @transfer.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /transfers/1
  # DELETE /transfers/1.json
  def destroy
    @transfer.destroy
    respond_to do |format|
      format.html { redirect_to transfers_url, notice: 'Transfer was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_transfer
      @transfer = Transfer.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def transfer_params
      params.require(:transfer).permit(:user_id, :amount, :description)
    end
end
