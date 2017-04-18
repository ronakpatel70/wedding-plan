require 'test_helper'

class LocationsControllerTest < BaseTest
  setup do
    @location = locations(:sr)
    stub_request(:post, "https://api.stripe.com/v1/refunds").to_return(:body => File.open('test/stubs/refund.json'))
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:locations)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create location" do
    assert_difference('Location.count') do
      post :create, params: { location: {name: 'Test', handle: 'test', address_attributes: {
        name: 'Test', street: '123 Main St', city: 'Windsor', state: 'CA', zip: '99999' } } }
    end

    assert_redirected_to locations_path
  end

  test "should show location" do
    get :show, params: { id: @location }
    assert_response :success
  end

  test "should update location" do
    patch :update, params: { id: @location, location: {
      name: 'Test', handle: 'test', address_attributes: {
        name: 'Test', street: '123 Main St', city: 'Windsor', state: 'CA', zip: '99999' } } }
    assert_redirected_to locations_path
  end

  test "should destroy location" do
    assert_difference('Location.count', -1) do
      delete :destroy, params: { id: locations(:windsor) }
    end

    assert_redirected_to locations_path
  end
end
