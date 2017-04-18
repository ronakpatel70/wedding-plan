require 'test_helper'

class JobApplicationsControllerTest < BaseTest
  setup do
    @job_app = job_applications(:one)
    @user = users(:dylan)
    @show = shows(:two)
  end

  test "should get index" do
    get :index, params: { show_id: @show }
    assert_response :success
    assert_not_nil assigns(:job_apps)
  end

  test "should get new" do
    get :new, params: { show_id: @show }
    assert_response :success
  end

  test "should create job_application" do
    assert_difference('JobApplication.count') do
      post :create, params: { job_application: { user_id: @user, requests: 'None', requested_start: '10:30', requested_end: '16:30' }, show_id: @show }
    end

    assert_redirected_to :job_applications
  end

  test "should create invalid job_application" do
    assert_difference('JobApplication.count', 0) do
      post :create, params: { job_application: { user_id: nil }, show_id: @show }
    end

    assert_response :success
    assert_not_nil assigns(:job_app)
  end

  test "should show job_application" do
    get :show, params: { id: @job_app }
    assert_response :success
  end

  test "should update job_application" do
    patch :update, params: { id: @job_app, job_application: { requested: 'Updated requests' } }
    assert_redirected_to :job_applications
  end

  test "should update invalid job_application" do
    patch :update, params: { id: @job_app, job_application: { user_id: nil } }
    assert_response :success
    assert_not_nil assigns(:job_app)
  end

  test "should destroy job_application" do
    assert_difference('JobApplication.count', -1) do
      delete :destroy, params: { id: @job_app }
    end

    assert_redirected_to :job_applications
  end
end
