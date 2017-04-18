require 'test_helper'

class TextsControllerTest < BaseTest
  setup do
    @text = texts(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:texts)

    get :index, params: { format: :json }
    assert_response :success
    assert_not_nil assigns(:texts)
  end

  test "should get texts for vendor" do
    get :index, params: { vendor: vendors(:one).id, format: :json }
    assert_response :success
    assert_equal 1, assigns(:texts).length
  end

  test "should get conversations" do
    get :conversations, params: { format: :json }
    assert_response :success
    assert_not_nil assigns(:vendors)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create text" do
    assert_difference('Text.count') do
      post :create, params: { text: { recipient: vendors(:one), message: 'Hi!' } }
    end

    assert_redirected_to texts_url
  end

  test "should show text" do
    get :show, params: { id: @text }
    assert_response :success
  end
end
