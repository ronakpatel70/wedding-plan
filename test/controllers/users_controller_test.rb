require 'test_helper'

class UsersControllerTest < BaseTest
  setup do
    @user = users(:dylan)
    stub_request(:any, "https://api.stripe.com/v1/customers/cus_79ZU2mLycWhs6c").to_return(:body => File.open('test/stubs/customer.json'))
    stub_request(:get, "https://api.stripe.com/v1/customers/cus_79ZU2mLycWhs6c/sources/card_16vGqV2RDM5ZUbA00snzKzqd").to_return(:body => File.open('test/stubs/card.json'))
    stub_request(:delete, "https://api.stripe.com/v1/customers/cus_79ZU2mLycWhs6c/sources/card_16vGqV2RDM5ZUbA00snzKzqd").to_return(:body => '{"deleted": true, "id": "card_16vGqV2RDM5ZUbA00snzKzqd"}')
    stub_request(:post, "https://api.stripe.com/v1/refunds").to_return(:body => File.open('test/stubs/refund.json'))
  end

  test "should get attendees" do
    get :index, params: { show_id: shows(:next).id }
    assert_response :success
    assert_not_nil assigns(:users)
  end

  test "should get mailing labels pdf" do
    get :index, params: { show_id: shows(:next).id, format: :pdf }
    assert_response :success
    assert_equal "application/pdf", response.content_type
    assert_not_nil assigns(:users)
  end

  test "should get new attendee" do
    redirect = show_attendees_path(shows(:next))
    get :new, params: { show_id: shows(:next).id, redirect: redirect }

    assert_response :success
    assert_equal shows(:next), assigns(:show)
    assert_equal redirect, flash[:redirect]
  end

  test "should get new contact" do
    redirect = vendor_path(vendors(:one))
    get :new, params: { vendor_id: vendors(:one).id, redirect: redirect }

    assert_response :success
    assert_equal vendors(:one), assigns(:vendor)
    assert_equal redirect, flash[:redirect]
  end

  test "should create attendee" do
    redirect = show_attendees_path(shows(:next))

    assert_difference('User.count') do
      post :create, params: { user: {
        first_name: 'Joe', last_name: 'Smith', email: 'joe@example.com', phone: '707-555-1234',
        password: 'testing123', events_attributes: {'0' => {date: '2019-01-01'}} } }, flash: { redirect: redirect }
    end

    assert_redirected_to redirect
    assert_equal Date.parse('2019-01-01'), assigns(:user).events.first.date
  end

  test "should create vendor contact" do
    assert_difference('User.count') do
      post :create, params: { user: {
        first_name: 'Joe', last_name: 'Smith', email: 'joe@example.com', phone: '707-555-1234',
        password: 'testing123', vendor_ids: [vendors(:one).id] } }, flash: { redirect: vendor_path(vendors(:one)) }
    end

    assert_redirected_to vendors(:one)
  end

  test "should show user" do
    get :show, params: { id: @user }
    assert_response :success
  end

  test "should get prize labels pdf" do
    get :show, params: { id: @user, format: :pdf }
    assert_response :success
    assert_equal "application/pdf", response.content_type
    assert_equal shows(:today), @user.shows.first
  end

  test "should get edit" do
    get :edit, params: { id: @user }
    assert_response :success
  end

  test "should update user" do
    session[:show_id] = shows(:next).id
    patch :update, params: { id: @user, user: {phone: '999-909-1234', password: 'newpassword'} }
    assert_redirected_to show_attendees_path(shows(:next))
  end

  test "should update user from settings" do
    @request.env['HTTP_REFERER'] = settings_url
    patch :update, params: { id: @user, user: {phone: '999-909-1234', password: 'newpassword'} }
    assert_redirected_to :settings
  end

  test "should destroy user" do
    assert_difference('User.count', -1) do
      delete :destroy, params: { id: users(:megan) }
    end

    assert_redirected_to :attendees
  end

  test "should not destroy user with paid tickets" do
    assert_difference('User.count', 0) do
      delete :destroy, params: { id: users(:dylan) }
    end

    assert_redirected_to users(:dylan)
  end

  test "should get login" do
    get :login, params: { id: @user }
    assert_redirected_to %r(^//weddingexpo\.co/account/login\?token=.{64,}$)
  end
end
