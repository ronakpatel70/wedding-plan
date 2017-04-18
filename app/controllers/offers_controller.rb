class OffersController < BaseController
  before_action :set_offer, only: [:update, :destroy]
  before_action :set_vendor, only: [:index, :create]

  # GET /offers
  # GET /offers.json
  def index
    @vendor = Vendor.find(params[:vendor_id])
    @offers = @vendor.offers.order(:tier)
  end

  # POST /offers
  # POST /offers.json
  def create
    @offer = Offer.new(offer_params)
    @offer.vendor = @vendor

    respond_to do |format|
      if @offer.save
        format.html { redirect_to vendor_offers_path(@offer.vendor), notice: 'Offer was successfully created.' }
        format.json { render :show, status: :created, location: @offer }
      else
        format.html { redirect_to vendor_offers_path(@offer.vendor), alert: @offer.errors.full_messages.first }
        format.json { render json: @offer.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /offers/1
  # PATCH/PUT /offers/1.json
  def update
    respond_to do |format|
      if @offer.update(offer_params)
        format.html { redirect_to vendor_offers_path(@offer.vendor), notice: 'Offer was successfully updated.' }
        format.json { render :show, status: :ok, location: @offer }
      else
        format.html { redirect_to vendor_offers_path(@offer.vendor), alert: @offer.errors.full_messages.first }
        format.json { render json: @offer.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /offers/1
  # DELETE /offers/1.json
  def destroy
    @offer.destroy
    respond_to do |format|
      format.html { redirect_to vendor_offers_path(@offer.vendor), flash: { warning: 'Offer was deleted.'} }
      format.json { head :no_content }
    end
  end

  private
    def set_offer
      @offer = Offer.find(params[:id])
    end

    def set_vendor
      @vendor = Vendor.find(params[:vendor_id])
    end

    def offer_params
      params.require(:offer).permit(:tier, :type, :value, :name, :rules, :combo)
    end
end