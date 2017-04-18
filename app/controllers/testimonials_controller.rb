class TestimonialsController < BaseController
  before_action :set_testimonial, only: [:show, :update, :destroy]
  before_action :set_vendor, only: [:index, :create]

  # GET /testimonials
  def index
    @testimonials = @vendor.testimonials
  end

  # POST /testimonials
  def create
    @testimonial = Testimonial.new(testimonial_params)
    @testimonial.vendor = @vendor

    if @testimonial.save
      redirect_to [@vendor, :testimonials], notice: "Testimonial was successfully created."
    else
      redirect_to [@vendor, :testimonials], alert: @testimonial.errors.full_messages.first
    end
  end

  # PATCH/PUT /testimonials/1
  def update
    if @testimonial.update(testimonial_params)
      redirect_to [@testimonial.vendor, :testimonials], notice: "Testimonial was successfully updated."
    else
      redirect_to [@testimonial.vendor, :testimonials], alert: @testimonial.errors.full_messages.first
    end
  end

  # DELETE /testimonials/1
  def destroy
    @testimonial.destroy
    redirect_to [@testimonial.vendor, :testimonials], flash: { warning: "Testimonial was deleted." }
  end

  private
    def set_testimonial
      @testimonial = Testimonial.find(params[:id])
    end

    def set_vendor
      @vendor = Vendor.find(params[:vendor_id])
    end

    def testimonial_params
      params.require(:testimonial).permit(:author, :quote)
    end
end
