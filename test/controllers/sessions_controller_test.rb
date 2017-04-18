require 'test_helper'

class SessionsControllerTest < ActionController::TestCase
  setup do
    @request.host = "admin.test.host"
  end

  test "should get index" do
    session[:admin_id] = users(:dylan).id
    session[:expires] = 72.hours.from_now
    get :index
    assert_response :success
  end

  test "should get index with token" do
    request.headers["Authorization"] = "Token token=abcdefghijkl"
    get :index
    assert_response :success
  end

  test "should get index with invalid token" do
    request.headers["Authorization"] = "Token token=wrong"
    assert_raises(ActiveRecord::RecordNotFound) do
      get :index
    end
  end

  test "should redirect to login" do
    get :index
    assert_redirected_to :new_session
  end

  test "should redirect expired session" do
    session[:admin_id] = users(:dylan).id
    session[:expires] = Date.yesterday.to_time
    get :index
    assert_redirected_to :new_session
    assert_not_nil session[:admin_id]
  end

  test "should redirect unauthorized user" do
    session[:admin_id] = users(:megan).id
    session[:expires] = 72.hours.from_now
    get :index
    assert_redirected_to :new_session
    assert_nil session[:admin_id]
  end

  test "should get new" do
    session.delete(:admin_id)
    get :new
    assert_response :success
  end

  test "should redirect to root when logged in" do
    session[:admin_id] = users(:dylan).id
    session[:expires] = 72.hours.from_now
    get :new
    assert_redirected_to :root
  end

  test "should ignore login token" do
    verifier = ActiveSupport::MessageVerifier.new(Rails.application.secrets[:secret_key_base])
    token = verifier.generate(users(:dylan).id)
    get :new, params: { token: token }

    assert_response :success
    assert_nil session[:admin_id]
  end

  test "should create session" do
    post :create, params: { session: { email: 'dylan@waits.io', password: 'testing123' } }

    assert_redirected_to :root
  end

  test "should redirect to original path after logging in" do
    old_controller = @controller

    @controller = SettingsController.new
    get :index

    @controller = old_controller
    post :create, params: { session: { email: 'dylan@waits.io', password: 'testing123' } }

    assert_redirected_to :settings
  end

  test "should return message for incorrect credentials" do
    post :create, params: { session: { email: 'dylan@waits.io', password: 'wrongpassword' } }
    assert_redirected_to :new_session
    assert_equal 'Incorrect email or password.', flash[:alert]

    post :create, params: { session: { email: 'noaccount@example.com', password: 'wrongpassword' } }
    assert_redirected_to :new_session
    assert_equal 'Incorrect email or password.', flash[:alert]
  end

  test "should return message for locked account" do
    post :create, params: { session: { email: 'locked@example.com', password: 'wrongpassword' } }

    assert_redirected_to :new_session
    assert_match /This account has been locked for [0-9] minutes\./, flash[:alert]
  end

  test "should destroy session" do
    session[:admin_id] = users(:dylan).id
    session[:expires] = 1.day.from_now
    delete :destroy
    assert_redirected_to :new_session
  end
end
