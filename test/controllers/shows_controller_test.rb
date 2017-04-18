require 'test_helper'

class ShowsControllerTest < BaseTest
  setup do
    @show = shows(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:shows)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create show" do
    assert_difference('Show.count') do
      post :create, params: { show: {location_id: locations(:sr).id,
        early_bird_price: 500, online_price: 700, door_price: 1300, prize_ribbons: 400,
        'date(1i)' => '2015', 'date(2i)' => '01', 'date(3i)' => '01',
        'start(1i)' => '2015', 'start(2i)' => '01', 'start(3i)' => '01', 'start(4i)' => '12', 'start(5i)' => '00',
        'end(1i)' => '2015', 'end(2i)' => '01', 'end(3i)' => '01', 'end(4i)' => '17', 'end(5i)' => '00'} }
    end

    assert_redirected_to shows_path
  end

  test "should show show" do
    get :show, params: { id: @show }
    assert_response :success
  end

  test "should update show" do
    patch :update, params: { id: @show, show: { date: '2015-09-21', start: '12:00', end: '17:00' } }
    assert_redirected_to shows_path

    patch :update, params: { id: @show, show: { early_bird_price: 1234, online_price: 555, door_price: 100, prize_ribbons: 400 } }
    assert_redirected_to shows_path
  end

  test "should destroy show" do
    assert_difference('Show.count', -1) do
      delete :destroy, params: { id: shows(:three) }
    end

    assert_redirected_to shows_path
  end

  test "should not destroy show with paid tickets" do
    assert_difference('Show.count', 0) do
      delete :destroy, params: { id: @show }
    end

    assert_redirected_to shows(:one)
  end
end
