class SubscriptionsController < BaseController
  before_action :set_subscription, only: [:show, :edit, :update, :destroy, :pay]

  # GET /subscriptions
  def index
    @subscriptions = Subscription.all.preload(:vendor => :default_card).order('status = 3, status IN (2, 4) DESC, current_period_end')
  end

  # GET /subscriptions/1
  def show
  end

  # GET /subscriptions/new
  def new
    @subscription = Subscription.new
  end

  # POST /subscriptions
  def create
    @subscription = Subscription.new(subscription_params)

    respond_to do |format|
      if @subscription.save
        format.html { redirect_to :subscriptions, notice: 'Subscription was successfully created.' }
        format.json { render :show, status: :created, location: @subscription }
      else
        format.html { render :new }
        format.json { render json: @subscription.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /subscriptions/1
  def update
    respond_to do |format|
      if @subscription.update(subscription_params)
        format.html { redirect_to :subscriptions, notice: 'Subscription was successfully updated.' }
        format.json { render :show, status: :ok, location: @subscription }
      else
        format.html { render :edit }
        format.json { render json: @subscription.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /subscriptions/1
  def destroy
    @subscription.destroy
    redirect_to :subscriptions, flash: { warning: 'Subscription was canceled.' }
  end

  # POST /subscriptions/1/pay
  def pay
    if @subscription.pay
      redirect_to :subscriptions, notice: 'Subscription was successfully paid.'
    else
      redirect_to :subscriptions, flash: {alert: 'Failed to pay subscription.'}
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_subscription
      @subscription = Subscription.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def subscription_params
      params.require(:subscription).permit(:vendor_id, :plan, :coupon, :trial_end)
    end
end
