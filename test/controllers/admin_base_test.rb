require 'test_helper'

class BaseTest < ActionController::TestCase
  setup do
    session[:admin_id] = users(:dylan).id
    session[:expires] = 1.day.from_now
    @request.host = "admin.test.host"
  end
end
