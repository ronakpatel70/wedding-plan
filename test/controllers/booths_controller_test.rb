require 'test_helper'

class BoothsControllerTest < BaseTest
  setup do
    @booth = booths(:one)
  end

  test "should get index" do
    get :index, params: { show_id: shows(:two) }
    assert_response :success
    assert_not_nil assigns(:booths)
  end

  test "should get index csv" do
    get :index, params: { show_id: shows(:two), format: :csv }
    assert_response :success
    assert_not_nil assigns(:booths)
    assert_equal "text/csv", response.content_type
    assert_match "Wine Country Bride,apparel,ineligible,approved,6x6", response.body
  end

  test "should get index json" do
    get :index, params: { show_id: shows(:two), format: :json }
    assert_response :success
    assert_not_nil assigns(:booths)
    assert_equal "application/json", response.content_type
  end

  test "should get door" do
    get :door, params: { show_id: shows(:two), door: "A", format: :json }
    assert_response :success
    assert_equal [], assigns(:booths)
    assert_equal "application/json", response.content_type

    get :door, params: { show_id: shows(:two), door: "7", format: :json }
    assert_response :success
    assert_equal [booths(:two)], assigns(:booths)
    assert_equal "application/json", response.content_type
  end

  test "should search booths" do
    get :search, params: { show_id: shows(:two), query: "wine", format: :json }
    assert_response :success
    assert_not_nil assigns(:booths)
    assert_equal "application/json", response.content_type
  end

  test "should get paper signs pdf" do
    get :index, params: { show_id: shows(:next).id, format: :pdf }
    assert_response :success
    assert_equal "application/pdf", response.content_type
  end

  test "should get new" do
    get :new, params: { show_id: shows(:one) }
    assert_response :success
  end

  test "should create booth" do
    assert_difference("Booth.count") do
      post :create, params: { booth: { vendor_id: vendors(:one), size: "6x6", payment_method: "card" }, show_id: shows(:one) }
    end

    assert_redirected_to booth_path(assigns(:booth))
  end

  test "should show booth" do
    get :show, params: { id: @booth }
    assert_response :success
  end

  test "should get edit" do
    get :edit, params: { id: @booth }
    assert_response :success
  end

  test "should get billing" do
    get :billing, params: { id: @booth }
    assert_response :success
  end

  test "should get addons" do
    get :addons, params: { id: @booth }
    assert_response :success
  end

  test "should update booth" do
    assert_difference("@booth.add_ons.count", 0) do
      patch :update, params: { id: @booth, booth: { size: "3x10" } }
    end
    assert_redirected_to booth_path(@booth)

    patch :update, params: { id: @booth, booth: { size: "6x8" }, format: :json }
    assert_response :success
  end

  test "should destroy add-ons" do
    assert_difference("@booth.add_ons.count", -1) do
      patch :update, params: { id: @booth, booth: { add_ons_attributes: [{id: @booth.add_ons.first.id, _destroy: true}] } }
    end
    assert_redirected_to booth_path(@booth)
  end

  test "should update coordinate" do
    patch :update, params: { id: @booth, booth: { coordinate_attributes: { x: 30.4, y: 11.1, a: 90, section: "7A" } } }
    c = assigns(:booth).coordinate
    assert_redirected_to booth_path(@booth)
    assert_equal 30.4, c.x.to_f
    assert_equal 11.1, c.y.to_f
    assert_equal 90, c.a.to_f
    assert_equal "7A", c.section
  end

  test "should update coordinate section" do
    patch :update, params: { id: @booth, booth: { coordinate_attributes: { id: @booth.coordinate_id, section: "Cake Pull" } } }
    c = assigns(:booth).coordinate
    assert_redirected_to booth_path(@booth)
    assert_equal "Cake Pull", c.section
  end

  test "should remove coordinate" do
    patch :update, params: {id: @booth, booth: {coordinate_id: nil } }

    assert_equal nil, assigns(:booth).coordinate
  end

  test "should destroy booth" do
    assert_difference("Booth.count", -1) do
      delete :destroy, params: { id: booths(:nothing) }
    end

    assert_redirected_to :booths
  end
end
