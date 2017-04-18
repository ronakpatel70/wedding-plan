require 'test_helper'

class ShiftsControllerTest < BaseTest
  setup do
    @shift = shifts(:one)
    @show = shows(:two)
  end

  test "should get index" do
    get :index, params: { show_id: @show }
    assert_response :success
    assert_not_nil assigns(:users)
    assert_not_nil assigns(:positions)
  end

  test "should get schedule" do
    get :schedule, params: { show_id: @show }
    assert_response :success
    assert_not_nil assigns(:users)
  end

  test "should get timesheet" do
    get :timesheet, params: { show_id: @show }
    assert_response :success
    assert_not_nil assigns(:users)
  end

  test "should create shift" do
    assert_difference('Shift.count') do
      post :create, params: { shift: { user_id: users(:dylan), position_id: positions(:door_host),
        start_time: '2015-10-29 10:00', end_time: '2015-10-29 10:00' }, show_id: @show }
    end

    assert_redirected_to :shifts
  end

  test "should show shift" do
    get :show, params: { id: @shift }
    assert_response :success
  end

  test "should update shift" do
    patch :update, params: { id: @shift, shift: { status: 'confirmed' } }
    assert_redirected_to :shifts
  end

  test "should update in_time" do
    time = '2015-01-01 12:24:01 -0800'
    patch :update, params: { id: @shift, shift: { in_time: time } }
    assert_redirected_to :shifts
    assert_equal DateTime.parse(time), @shift.reload.in_time
  end

  test "should update out_time" do
    time = '2015-01-01 15:05:00 -0800'
    patch :update, params: { id: @shift, shift: { out_time: time } }
    @shift.reload
    assert_redirected_to :shifts
    assert_equal DateTime.parse(time), @shift.reload.out_time.to_datetime
  end

  test "should destroy shift" do
    assert_difference('Shift.count', -1) do
      delete :destroy, params: { id: @shift }
    end

    assert_redirected_to :shifts
  end
end
