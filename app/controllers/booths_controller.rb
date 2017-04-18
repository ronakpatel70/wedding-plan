class BoothsController < BaseController
  include Pdf

  protect_from_forgery except: :update
  before_action :set_booth, only: [:show, :edit, :update, :destroy, :addons, :billing]
  before_action :set_show, only: [:index, :new, :create, :paper_signs, :door, :search]
  layout "booth", only: [:show, :edit, :addons, :billing]

  # GET /booths
  # GET /booths.json
  def index
    @booths = @current_show.booths.select("booths.*, COUNT(payments.*) AS scheduled_payment_count")
      .joins("LEFT JOIN payments ON payments.payable_type = 'Booth' AND payments.payable_id = booths.id AND payments.status = 6")
      .where.not(status: 2).group("booths.id").order("status ASC, updated_at DESC")
    @pending = @current_show.booths.pending.count
    @denied = @current_show.booths.denied.preload(:vendor)
    @booths = @booths.preload(:add_ons, :coordinate, :sign, :vendor => :storefront_address)
    @count = @current_show.booths.approved.count
    @add_ons = Hash[@booths.map { |b| [b.id, Hash[b.add_ons.map { |a| [a.type, a.to_s.escape_csv] }]] }]
  end

  # GET /shows/1/booths/7.json
  def door
    section_map = Hash.new
    Config.sections.each { |k, v| section_map[v.to_s] ||= Array.new; section_map[v.to_s] << k }
    valid_sections = section_map[params[:door]]
    @booths = @current_show.booths.joins(:coordinate, :vendor).approved.
      where("coordinates.section in (?)", valid_sections).order("vendors.name").
      preload(:add_ons, :coordinate, :sign, :vendor)
    render :index
  end

  # GET /shows/1/booths/search.json
  def search
    @booths = @current_show.booths.joins(:vendor).approved.
      where("vendors.name ILIKE ?", "%#{params[:query]}%").order("vendors.name").
      preload(:add_ons, :coordinate, :sign, :vendor)
    render :index
  end

  # GET /booths/paper-signs.pdf
  def paper_signs
    booths_without_signs = @current_show.booths.approved.where(sign: nil).preload(:vendor)
    pdf = paper_signs_pdf(booths_without_signs)
    send_data(pdf.render, disposition: 'inline', filename: 'paper_signs.pdf')
  end

  # GET /booths/1
  # GET /booths/1.json
  def show
  end

  # GET /booths/1/addons
  def addons
    @add_ons = @booth.add_ons.order(:created_at)
    @add_ons = [@booth.add_ons.new(type: :bag_promo)] if @booth.add_ons.empty?
  end

  # GET /booths/1/billing
  def billing
    @payments = Payment.where(payable: @booth).order("scheduled_for ASC, captured_at DESC").preload(:card)
    @pending_balance = @booth.balance - @payments.scheduled.sum(:amount)
  end

  # GET /booths/1/edit
  def edit
  end

  # GET /booths/new
  def new
    @booth = Booth.new
  end

  # POST /booths
  # POST /booths.json
  def create
    @booth = Booth.new(booth_params)
    @booth.show = @current_show

    respond_to do |format|
      if @booth.save
        format.html { redirect_to @booth, notice: "Booth was successfully created." }
        format.json { render :show, status: :created, location: @booth }
      else
        format.html { render :new }
        format.json { render json: @booth.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /booths/1
  # PATCH/PUT /booths/1.json
  def update
    return render(:edit) unless @booth.update(booth_params)
    redirect = request.referer || booth_path(@booth)
    respond_to do |format|
      format.html { redirect_to redirect, notice: "Booth was successfully updated." }
      format.json { render :show, status: :ok, location: @booth }
    end
  end

  # DELETE /booths/1
  # DELETE /booths/1.json
  def destroy
    respond_to do |format|
      if @booth.destroy
        format.html { redirect_to booths_url, flash: { warning: "Booth was deleted." } }
      else
        msg = if @booth.errors.present?
          @booth.errors.full_messages.join(".\n") + "."
        else "Booth could not be deleted." end
        format.html { redirect_to @booth, alert: msg }
      end
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_booth
      @booth = Booth.find(params[:id])
      @inactive_show = @booth.show
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def booth_params
      params.require(:booth).permit(:vendor_id, :status, :section_requested, :size, :requests, :payment_method, :checked_in_at,
        :payment_schedule, :card_id, :coordinate_id, :sign_id, :visible, :leads_access, :flagged, :received_marketing, :free_pass_limit,
        :industries => [], :coordinate_attributes => [:id, :x, :y, :a, :section], :add_ons_attributes => [:_destroy, :id, :type, :value, :quantity, :price, :description])
    end
end
