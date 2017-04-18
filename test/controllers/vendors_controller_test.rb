require 'test_helper'

class VendorsControllerTest < BaseTest
  setup do
    @vendor = vendors(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:vendors)
  end

  test "should filter vendors" do
    get :index, params: { rewards_status: 'eligible' }
    assert_response :success
    assert_equal 2, assigns(:vendors).length
    assert_equal 2, assigns(:count)

    get :index, params: { industry: 'apparel' }
    assert_response :success
    assert_equal 3, assigns(:vendors).length
    assert_equal 3, assigns(:count)

    get :index, params: { rewards_status: 'applied', industry: 'dj' }
    assert_response :success
    assert_equal 1, assigns(:vendors).length
    assert_equal 1, assigns(:count)
  end

  test "should filter by show status" do
    get :index, params: { show: '1', status: 'interested' }
    assert_response :success
    assert_equal 2, assigns(:vendors).length
    assert_equal 2, assigns(:count)

    get :index, params: { show: '1', status: 'lead' }
    assert_response :success
    assert_equal 3, assigns(:vendors).length
    assert_equal 3, assigns(:count)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create vendor" do
    assert_difference('Vendor.count') do
      post :create, params: { vendor: { name: 'Test', email: 'test@example.com', phone: '707.544.3695',
        contact: 'Cirkl', industry: 'apparel', allow_multi_points: true,
          billing_address_attributes:
            { street: '123 Main St', city: 'Windsor', state: 'CA', zip: '99999' } } }
    end

    assert_equal '123 Main St', assigns(:vendor).billing_address.street
    assert_redirected_to vendor_path(assigns(:vendor))
  end

  test "should show vendor" do
    get :show, params: { id: @vendor }
    assert_response :success

    get :show, params: { id: vendors(:two) }
    assert_response :success
  end

  test "should get edit" do
    get :edit, params: { id: @vendor }
    assert_response :success
  end

  test "should update vendor" do
    patch :update, params: { id: @vendor, vendor: { name: 'New Business Name', allow_multi_points: true } }
    assert_redirected_to vendor_path(assigns(:vendor))

    sid = shows(:following).id.to_s
    patch :update, params: { id: @vendor, vendor: { show_statuses: { sid => 'excluded' } } }
    assert_redirected_to vendor_path(assigns(:vendor))
    assert_equal 'excluded', assigns(:vendor).show_statuses[sid]
  end

  test "should destroy vendor" do
    assert_difference('Vendor.count', -1) do
      delete :destroy, params: { id: vendors(:two).id }
    end

    assert_redirected_to vendors_path
  end

  test "should fail to destroy vendor" do
    vendor = vendors(:one)
    assert_difference('Vendor.count', 0) do
      delete :destroy, params: { id: vendor.id }
    end

    assert_redirected_to vendor
    assert_equal "Cannot delete record because dependent payments exist.", flash[:alert]
  end

  test "should get merge" do
    get :merge, params: { id: @vendor }
  end

  test "should merge vendors" do
    @into = vendors(:two)
    post :merge_into, params: { id: @vendor, duplicate_vendor_id: @into.id }

    assert_redirected_to vendor_path(assigns(:vendor))
    assert_equal flash[:notice], "Successfully merged #{@into} into #{@vendor}."
    assert assigns(:into).destroyed?
  end
end
