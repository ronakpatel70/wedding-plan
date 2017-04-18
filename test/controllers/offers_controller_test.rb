require 'test_helper'

class OffersControllerTest < BaseTest
  setup do
    @offer = offers(:one)
    @vendor = vendors(:one)
  end

  test "should get index" do
    get :index, params: { vendor_id: @vendor }
    assert_response :success
    assert_not_nil assigns(:offers)
  end

  test "should create offer" do
    assert_difference('Offer.count') do
      post :create, params: { offer: { tier: 3, type: :percent, name: 'Offer' }, vendor_id: @vendor }
    end

    assert_redirected_to vendor_offers_path(@offer.vendor)
  end

  test "should update offer" do
    patch :update, params: { id: @offer, offer: { tier: 3 } }
    assert_redirected_to vendor_offers_path(@offer.vendor)
  end

  test "should destroy offer" do
    assert_difference('Offer.count', -1) do
      delete :destroy, params: { id: @offer }
    end

    assert_redirected_to vendor_offers_path(@offer.vendor)
  end
end
