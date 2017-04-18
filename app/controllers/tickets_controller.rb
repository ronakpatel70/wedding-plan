class TicketsController < BaseController
  before_action :set_ticket, only: [:update, :destroy]
  before_action :set_show, only: [:index, :new, :create, :link]

  # GET /tickets
  # GET /tickets.json
  def index
    @tickets = if params[:free] then @current_show.tickets.free else @current_show.tickets.not_free end
    @tickets = @tickets.preload(:payment, :user).order("created_at DESC")
  end

  # GET /tickets/new
  def new
    @ticket = Ticket.new
  end

  # POST /tickets
  # POST /tickets.json
  def create
    @ticket = Ticket.new(ticket_params)
    @ticket.show = @current_show
    if @ticket.free then route, item = :passes, 'Free pass' else route, item = :tickets, 'Ticket' end

    respond_to do |format|
      if @ticket.save
        format.html { redirect_to route, notice: "#{item} was successfully created." }
        format.json { render :show, status: :created, location: @ticket }
      else
        format.html { render :new }
        format.json { render json: @ticket.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /tickets/1
  # PATCH/PUT /tickets/1.json
  def update
    respond_to do |format|
      if @ticket.update(ticket_params)
        format.html { redirect_to :tickets, notice: 'Ticket was successfully updated.' }
        format.json { render :show, status: :ok, location: @ticket }
      else
        format.html { render :edit }
        format.json { render json: @ticket.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /tickets/1
  # DELETE /tickets/1.json
  def destroy
    if @ticket.free then route, msg = :passes, 'Free pass was deleted.' else route, msg = :tickets, 'Ticket was refunded.' end
    @ticket.destroy
    respond_to do |format|
      format.html { redirect_to route, flash: { warning: msg } }
      format.json { head :no_content }
    end
  end

  # GET /shows/1/passes/link
  def link
    verifier = ActiveSupport::MessageVerifier.new(Rails.application.secrets[:public_site_secret_key])
    message = verifier.generate(@current_show.id)
    args = {token: message}.to_param
    render plain: "https://weddingexpo.co/account/tickets/redeem?#{args}"
  end

  private
    def set_ticket
      @ticket = Ticket.find(params[:id])
      @inactive_show = @ticket.show
    end

    def ticket_params
      params.require(:ticket).permit(:user_id, :show_id, :quantity, :payment_method, :vendor_id, :free)
    end
end
