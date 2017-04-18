require 'test_helper'

class SearchControllerTest < BaseTest
  test "should search by name" do
    get :index, params: { query: 'waits', format: :json }
    assert_response :success
    assert_equal 4, JSON.parse(response.body).length

    get :index, params: { query: 'waits', format: :html }
    assert_response :success
    assert_equal 4, assigns(:results).length
  end

  test "should search by full name" do
    get :index, params: { query: 'dylan waits', format: :json }
    assert_response :success
    assert_equal 2, JSON.parse(response.body).length

    get :index, params: { query: 'waits dylan', format: :json }
    assert_response :success
    assert_equal 2, JSON.parse(response.body).length
  end

  test "should search by email" do
    get :index, params: { query: 'dylan@waits.io', format: :json }
    assert_response :success
    assert_equal 2, JSON.parse(response.body).length

    get :index, params: { query: 'dylan@waits.io', format: :html }
    assert_response :success
    assert_equal 2, assigns(:results).length
  end

  test "should search by phone" do
    get :index, params: { query: '7075272685', format: :json }
    assert_response :success
    assert_equal 2, JSON.parse(response.body).length

    get :index, params: { query: '7075272685', format: :html }
    assert_response :success
    assert_equal 2, assigns(:results).length
  end

  test "should search by business name" do
    get :index, params: { query: 'wine country weddings', format: :json }
    assert_response :success
    assert_equal 1, JSON.parse(response.body).length

    get :index, params: { query: 'wine country weddings', format: :html }
    assert_response :success
    assert_equal 1, assigns(:results).length
  end

  test "should filter by vendors" do
    get :index, params: { filter: 'vendors', query: 'wine', format: :html }
    assert_response :success
    assert_equal 3, assigns(:results).length
  end

  test "should filter by users" do
    get :index, params: { filter: 'users', query: 'waits', format: :html }
    assert_response :success
    assert_equal 2, assigns(:results).length
  end

  test "should filter by prizes" do
    get :index, params: { filter: 'prizes', query: 'cheap', status: 'approved', format: :html }
    assert_response :success
    assert_equal 1, assigns(:results).length

    get :index, params: { filter: 'prizes', query: 'cheap', status: 'approved', type: 'grand', format: :html }
    assert_response :success
    assert_equal 0, assigns(:results).length

    get :index, params: { filter: 'prizes', query: 'prize', show: shows(:three), status: 'approved', format: :html }
    assert_response :success
    assert_equal 1, assigns(:results).length

    get :index, params: { filter: 'prizes', query: 'prize', status: 'denied', format: :html }
    assert_response :success
    assert_equal 0, assigns(:results).length
  end

  test "should filter by positions" do
    get :index, params: { filter: 'positions', query: 'cashier', format: :html }
    assert_response :success
    assert_equal 1, assigns(:results).length
  end

  test "should filter by signs" do
    get :index, params: { filter: 'signs', query: 'premier', format: :html }
    assert_response :success
    assert_equal 1, assigns(:results).length
  end

  test "should limit results" do
    get :index, params: { query: 'wine', limit: 1, format: :json }
    assert_equal 1, JSON.parse(response.body).length

    get :index, params: { query: 'wine', limit: 2, format: :json }
    assert_equal 2, JSON.parse(response.body).length
  end
end
