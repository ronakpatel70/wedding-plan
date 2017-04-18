class PaymentsController < BaseController
  before_action :set_payment, only: [:show, :update, :destroy, :pay]

  # GET /payments
  def index
    @payments = Payment.where("payer_type = 'Vendor' AND captured_at > ? OR status = 6", Date.today - 60.days)
      .order("scheduled_for ASC, captured_at DESC")
    @scheduled = Payment.where(status: 6).count
    @payments.preload!(:payer).preload!(:card)
  end

  # GET /payments/1
  def show
    @editable = @payment.scheduled? && @payment.scheduled_for != nil
  end

  # GET /payments/new
  def new
    if params[:booth_id]
      @payable = @booth = Booth.find(params[:booth_id])
      @payer = @booth.vendor
      @payment = Payment.new(payable: @booth, payer: @payer, amount: @booth.balance)
    else
      @payer = Vendor.find(params[:vendor_id])
      @payment = Payment.new(payer: @payer, amount: 0)
    end
    @editable = true
  end

  # POST /payments
  # POST /payments.json
  def create
    params[:payment][:amount].gsub!(/[$,]/, "")
    params[:payment][:amount] = (params[:payment][:amount].to_f * 100).to_i
    @payment = Payment.new(payment_params)

    if params[:booth_id]
      @payable = @booth = Booth.find(params[:booth_id])
      @payer = @booth.vendor
    else
      @payer = Vendor.find(params[:vendor_id])
    end

    @payment.payer = @payer
    @payment.payable = @payable

    if @payment.save
      if @payment.errors.empty?
        redirect_to(@payment.payable || @payment.payer, notice: "Payment was successfully created.")
      else
        redirect_to(@payment.payable || @payment.payer, alert: @payment.errors.full_messages.join(".\n") + ".")
      end
    else
      @editable = true
      render(:new)
    end
  end

  # PATCH/PUT /payments/1
  # PATCH/PUT /payments/1.json
  def update
    [:amount, :refund_amount].each do |a|
      next unless params[:payment].has_key?(a)
      params[:payment][a].gsub!(/[$,]/, "")
      params[:payment][a] = (params[:payment][a].to_f * 100).to_i
    end

    respond_to do |format|
      if @payment.update(payment_params)
        format.html { redirect_to :payments, notice: "Payment was successfully updated." }
        format.json { render :show, status: :ok, location: @payment }
      else
        @editable = true
        format.html { render :show }
        format.json { render json: @payment.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /payments/1
  # DELETE /payments/1.json
  def destroy
    @payment.destroy
    respond_to do |format|
      format.html { redirect_to :payments, flash: { warning: "Payment was deleted." } }
      format.json { head :no_content }
    end
  end

  # POST /payments/1/pay
  def pay
    if @payment.charge_now!(save: true)
      redirect_to :payments, notice: "Payment was successfully paid."
    else
      redirect_to :payments, flash: {alert: "Failed to pay payment."}
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_payment
      @payment = Payment.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def payment_params
      params.require(:payment).permit(:amount, :refund_amount, :description, :method, :card_id, :scheduled_for)
    end
end
