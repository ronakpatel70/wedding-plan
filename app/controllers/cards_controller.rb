class CardsController < BaseController
  before_action :set_card, only: [:show, :destroy]
  before_action :set_owner, only: [:index, :new, :create]

  # GET /users/1/cards
  # GET /vendors/1/cards
  def index
    @cards = Card.where(owner: @owner)
  end

  # GET /users/1/cards/new
  # GET /vendors/1/cards/new
  def new
    @card = Card.new
    @card.owner = @owner
  end

  # GET /cards/1
  def show
    render json: @card
  end

  # POST /users/1/cards
  # POST /vendors/1/cards
  def create
    @card = Card.create_with_token(params[:card][:stripe_token], @owner)

    respond_to do |format|
      if @card.persisted?
        format.html { redirect_to @card.owner, notice: 'Card was successfully created.' }
      else
        format.html { render :new }
      end
    end
  end

  # DELETE /cards/1
  def destroy
    @card.deleted!
    respond_to do |format|
      format.html { redirect_to @card.owner, notice: 'Card was deleted.' }
    end
  end

  private
    def set_card
      @card = Card.find(params[:id])
    end

    def set_owner
      if id = params[:user_id]
        @owner = User.find(id)
      elsif id = params[:vendor_id]
        @owner = Vendor.find(id)
      else
        raise ActionController::RoutingError.new("Card owner not specified.")
      end
    end
end
