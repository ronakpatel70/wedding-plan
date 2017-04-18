require 'test_helper'

class JobApplicationTest < ActiveSupport::TestCase

  setup do
    @user = users(:dylan)
    @show = shows(:two)
  end

  test 'should save valid job application' do
    app = JobApplication.new(user: @user, show: @show, requests: 'This is a request.', requested_start: '10:30', requested_end: '16:30')
    assert app.save
  end

  test 'should not save without show' do
    app = JobApplication.new(user: @user, show: nil, requests: 'This is a request.', requested_start: '10:30', requested_end: '16:30')
    assert_not app.save
  end

  test 'should not save without user' do
    app = JobApplication.new(user: nil, show: @show, requests: 'This is a request.', requested_start: '10:30', requested_end: '16:30')
    assert_not app.save
  end

  test 'should not save duplicate user and show' do
    app = JobApplication.new(user: @user, show: shows(:one), requests: 'This is a request.', requested_start: '10:30', requested_end: '16:30')
    assert_not app.save
  end

end
