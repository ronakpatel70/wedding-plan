require 'test_helper'

class SettingsControllerTest < BaseTest
  test "should get index" do
    get :index

    assert_response :success
    assert assigns(:user)
  end

  test "should post markdown to preview" do
    @request.env['RAW_POST_DATA'] = "### Header\n_italic_\n> Quote"
    get :preview, params: { markdown: "### Header\n_italic_\n> Quote" }

    html = "<h3>Header</h3><p><em>italic</em></p><blockquote><p>Quote</p></blockquote>"

    assert_response :success
    assert_equal html, @response.body.gsub("\n", '')
  end
end
