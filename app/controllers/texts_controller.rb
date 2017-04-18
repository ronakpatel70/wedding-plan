class TextsController < BaseController
  before_action :set_text, only: [:show]

  # GET /texts
  # GET /texts.json
  def index
    if params[:vendor]
      @texts = Text.where("sender_id = :id OR recipient_id = :id", id: params[:vendor]).order(:created_at)
      unread = @texts.unread
      unread.update_all(status: 2)
    else
      @texts = Text.all.order('created_at DESC').preload(:sender, :recipient)
    end
  end

  # GET /texts/1
  # GET /texts/1.json
  def show
    @text.read! if @text.unread?
  end

  # GET /texts/new
  def new
    @text = Text.new
    @groups = Text.groups.keys
  end

  # POST /texts
  # POST /texts.json
  def create
    params[:text][:recipient_type] = 'Vendor' if params[:text][:recipient_id]
    @text = Text.new(text_params)

    respond_to do |format|
      if @text.save
        format.html { redirect_to :texts, notice: 'Text was successfully created.' }
        format.json { render :show, status: :created, location: @text }
      else
        @groups = Text.groups.keys
        format.html { render :new }
        format.json { render json: @text.errors, status: :unprocessable_entity }
      end
    end
  end

  # GET /texts/conversations
  def conversations
    headers['Time'] = Time.now.to_i.to_s
    since = params.has_key?(:since) ? Time.at(params[:since].to_i) : Time.now - 90.days
    @vendors = Vendor.select('DISTINCT ON (vendors.id) vendors.*, texts.id AS text_id, texts.message AS text_message,
      texts.status AS text_status, texts.created_at AS text_created_at').joins("INNER JOIN texts ON sender_id = vendors.id OR
      recipient_id = vendors.id").where("texts.message NOT ILIKE 'Hello!' AND texts.created_at > ?", since).
      group('vendors.id, texts.id').order('vendors.id, texts.created_at DESC')
    @vendors = @vendors.sort_by { |v| [v.text_status, v.text_created_at] }
    @statuses = Text.statuses
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_text
      @text = Text.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def text_params
      params.require(:text).permit(:recipient_id, :recipient_type, :group, :message)
    end
end
