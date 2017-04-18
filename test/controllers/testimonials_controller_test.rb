require "test_helper"

class TestimonialsControllerTest < BaseTest
  setup do
    @testimonial = testimonials(:one)
    @vendor = vendors(:one)
  end

  test "should get index" do
    get :index, params: { vendor_id: @vendor }
    assert_response :success
    assert_not_nil assigns(:vendor)
    assert_equal 1, assigns(:testimonials).length
  end

  test "should create testimonial" do
    assert_difference("Testimonial.count") do
      post :create, params: { testimonial: { quote: "Hi", author: "Dylan" }, vendor_id: @vendor }
    end

    assert_redirected_to vendor_testimonials_path(@testimonial.vendor)
  end

  test "should show error on create" do
    assert_difference("Testimonial.count", 0) do
      post :create, params: { testimonial: { author: "Nobody" }, vendor_id: @vendor }
    end

    assert_redirected_to vendor_testimonials_path(@testimonial.vendor)
    assert_equal "Quote can't be blank", flash[:alert]
  end

  test "should update testimonial" do
    patch :update, params: { id: @testimonial, testimonial: { quote: "Hi" } }
    assert_redirected_to vendor_testimonials_path(@testimonial.vendor)
  end

  test "should show error on update" do
    patch :update, params: { id: @testimonial, testimonial: { quote: "" } }

    assert_redirected_to vendor_testimonials_path(@testimonial.vendor)
    assert_equal "Quote can't be blank", flash[:alert]
  end

  test "should destroy testimonial" do
    assert_difference("Testimonial.count", -1) do
      delete :destroy, params: { id: @testimonial }
    end

    assert_redirected_to vendor_testimonials_path(@testimonial.vendor)
  end
end
