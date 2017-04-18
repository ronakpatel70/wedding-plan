require 'test_helper'

class PackagesControllerTest < BaseTest
  setup do
    @package = packages(:one)
    @show = shows(:one)
  end

  test "should get index" do
    get :index, params: { show_id: @show }
    assert_response :success
    assert_not_nil assigns(:packages)
  end

  test "should get index csv" do
    get :index, params: { show_id: @show, format: :csv }
    assert_response :success
    assert_equal "text/csv", response.content_type
    assert_not_nil assigns(:packages)
  end

  test "should get vendors csv" do
    get :vendors, params: { show_id: @show, format: :csv }
    assert_response :success
    assert_equal "text/csv", response.content_type
    assert_not_nil assigns(:vendors)
  end

  test "should get new" do
    get :new, params: { show_id: @show }
    assert_response :success
  end

  test "should create package" do
    assert_difference('Package.count') do
      post :create, params: { package: { name: 'Wedding Reception Giveaway', type: 'grand', rules: 'No rules', prize_ids: [prizes(:one), prizes(:two)] }, show_id: @show }
    end

    assert_redirected_to :packages
  end

  test "should show package" do
    get :show, params: { id: @package }
    assert_response :success
  end

  test "should update package" do
    patch :update, params: { id: @package, package: { name: 'Makeover Giveaway' } }
    assert_redirected_to :packages
  end

  test "should destroy package" do
    assert_difference('Package.count', -1) do
      delete :destroy, params: { id: @package }
    end

    assert_redirected_to :packages
  end
end
