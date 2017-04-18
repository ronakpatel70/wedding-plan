class VendorsController < BaseController
  before_action :set_vendor, only: [:show, :edit, :update, :destroy, :merge, :merge_into]

  # GET /vendors
  # GET /vendors.json
  def index
    @filters = params.permit(:rewards_status, :industry)
    vendors = Vendor.where(@filters)

    if params[:show] && params[:status]
      if params[:status] == "lead"
        vendors = vendors.where("NOT show_statuses ? :show", show: params[:show])
      else
        vendors = vendors.where("show_statuses @> hstore(?, ?)", params[:show], params[:status])
      end
    end

    @count = vendors.count
    @vendors = vendors.eager_load(:offers, :subscriptions, :users).order("vendors.created_at DESC")
    @vendors.limit!(100) if @count > 200
    @filters = params.permit(:rewards_status, :industry, :show, :status)
  end

  # GET /vendors/1
  # GET /vendors/1.json
  def show
  end

  # GET /vendors/new
  def new
    @vendor = Vendor.new
  end

  # GET /vendors/1/edit
  def edit
    @vendor.billing_address ||= Address.new
    @vendor.storefront_address ||= Address.new
  end

  # POST /vendors
  # POST /vendors.json
  def create
    @vendor = Vendor.new(vendor_params)

    respond_to do |format|
      if @vendor.save
        format.html { redirect_to @vendor, notice: "Vendor was successfully created." }
        format.json { render :show, status: :created, location: @vendor }
      else
        format.html { render :new }
        format.json { render json: @vendor.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /vendors/1
  # PATCH/PUT /vendors/1.json
  def update
    ss = params[:vendor][:show_statuses]&.permit!&.reject! { |k, v| v.blank? }.to_h
    @vendor.show_statuses = ss if ss

    # Update vendor
    CampaignMonitor.update_subscribers(:vendors, update_subscriber_array(@vendor), params[:vendor][:email])

    respond_to do |format|
      if @vendor.update(vendor_params)

        format.html { redirect_to @vendor, notice: "Vendor was successfully updated." }
        format.json { render :show, status: :ok, location: @vendor }
      else
        format.html { render :edit }
        format.json { render json: @vendor.errors, status: :unprocessable_entity }
      end
    end
  end

  def update_subscriber_array(object)
    future_shows = Show.select('id, start').future.order('start DESC').to_a
    subscribers = []

    custom = []
    if object.is_a?(Vendor)
      custom << ['ContactName', object.primary&.first_name]
      custom << ['Industry', object.industry]
      custom << ['RewardsStatus', object.rewards_status]
      custom << ['LastShow', last_show_date(object)]
      custom << ['NextShow', nsd = next_show_date(object.id)]
      custom << ['StorefrontAddress', object.storefront_address&.to_s]
      unless nsd
        custom << ['NextShowInterestedIn', next_show_with_status(object, 'interested', future_shows)]
        custom << ['NextShowLeadFor', next_show_without_status(object, future_shows)]
      end
    else
      custom << ['WeddingDate', object.events.first&.date]
      custom << ['RewardsJoinDate', object.events.first&.joined_rewards_at&.to_date&.to_s(:db)]
      custom << ['City', object.address&.city]
      custom << ['LastShow', last_show_date(object)]
    end
    subscribers << [object.to_s, object.email, custom]

    return subscribers
  end

  def last_show_date(obj)
    if obj.is_a? Vendor
      booth = Booth.joins(:show).includes(:show).approved.where("vendor_id = ? AND shows.start < ?", obj.id, Date.today).order('shows.start DESC').limit(1).first
      booth&.show&.date&.to_s(:db)
    else
      obj.shows.where("start < ?", Date.today).order('shows.start DESC').limit(1).first&.date&.to_s(:db)
    end
  end

  def next_show_date(vid)
    booth = Booth.joins(:show).includes(:show).approved.where("vendor_id = ? AND shows.start >= ?", vid, Date.today).order('shows.start ASC').limit(1).first
    booth&.show&.date&.to_s(:db)
  end

  def next_show_with_status(vendor, status, future_shows)
    show_ids = vendor.show_statuses.select { |sh, st| st == status }.keys
    shows = future_shows.select { |sh| show_ids.include?(sh.id.to_s) }
    return shows[0]&.date&.to_s(:db)
  end

  def next_show_without_status(vendor, future_shows)
    shows = future_shows.reject { |sh| vendor.show_statuses.has_key?(sh.id.to_s) }
    return shows[0]&.date&.to_s(:db)
  end

  # DELETE /vendors/1
  # DELETE /vendors/1.json
  def destroy
    if @vendor.destroy
      redirect_to vendors_url, notice: "Vendor was successfully destroyed."
    else
      msg = if @vendor.errors.present?
        @vendor.errors.full_messages.join(".\n") + "."
      else "Failed to delete #{@vendor}." end
      redirect_to @vendor, alert: msg
    end
  end

  # GET /vendors/1/merge
  def merge
  end

  # POST /vendors/1/merge
  def merge_into
    @into = Vendor.find(params[:duplicate_vendor_id])
    if @vendor.merge(@into)
      redirect_to @vendor, notice: "Successfully merged #{@into} into #{@vendor}."
    else
      redirect_to @vendor, alert: "Failed to merge #{@into} into #{@vendor}."
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_vendor
     @vendor = Vendor.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def vendor_params
      params.require(:vendor).permit(:name, :former_name, :email, :phone, :cell_phone, :contact, :industry, :website,:old_email,
        :facebook, :default_card, :rewards_status, :rewards_profile, :profile_image, :grab_card_status, :has_slides,
        :default_card_id, :allow_multi_points, :billing_address_attributes => [:street, :city, :state, :zip],
        :storefront_address_attributes => [:street, :city, :state, :zip])
    end
end
