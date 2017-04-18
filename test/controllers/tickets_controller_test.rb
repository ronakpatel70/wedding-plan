require 'test_helper'

class TicketsControllerTest < BaseTest
  setup do
    @ticket = tickets(:one)
    stub_request(:post, "https://api.stripe.com/v1/charges").to_return(:body => File.open('test/stubs/token.json'))
    stub_request(:post, "https://api.stripe.com/v1/refunds").to_return(:body => File.open('test/stubs/refund.json'))
  end

  test "should get index" do
    get :index, params: { show_id: shows(:one) }
    assert_response :success
    assert_not_nil assigns(:tickets)

    get :index, params: { show_id: shows(:one), free: true }
    assert_response :success
    assert_not_nil assigns(:tickets)
  end

  test "should get index csv" do
    get :index, params: { show_id: shows(:one), format: :csv }
    assert_response :success
    assert_not_nil assigns(:tickets)
    assert_equal "text/csv", response.content_type
    assert_match "Dylan Waits,dylan@waits.io,2,$1.00,card", response.body

    get :index, params: { show_id: shows(:one), free: true, format: :csv }
    assert_response :success
    assert_not_nil assigns(:tickets)
    assert_equal "text/csv", response.content_type
    assert_match "Dylan Waits,dylan@waits.io,1,$0,free", response.body
  end

  test "should get new" do
    get :new, params: { show_id: shows(:one) }
    assert_response :success
  end

  test "should create ticket" do
    assert_difference('Ticket.count') do
      post :create, params: { ticket: { quantity: 1, payment_method: 'card', user_id: users(:dylan).id }, show_id: shows(:one) }
    end

    assert_redirected_to :tickets
  end

  test "should create ticket for user without card" do
    assert_difference('Ticket.count', 0) do
      post :create, params: { ticket: { quantity: 1, payment_method: 'card', user_id: users(:megan).id }, show_id: shows(:one) }
    end

    assert_not_nil assigns(:ticket)
  end

  test "should create cash ticket" do
    assert_difference('Ticket.count', 1) do
      post :create, params: { ticket: { quantity: 1, payment_method: 'cash', user_id: users(:megan).id }, show_id: shows(:one) }
    end

    assert_redirected_to :tickets
  end

  test "should create free pass" do
    assert_difference('Ticket.free.count') do
      post :create, params: { ticket: { free: true, quantity: 1, user_id: users(:dylan).id }, show_id: shows(:one) }
    end

    assert_redirected_to :passes
  end

  test "should update ticket" do
    patch :update, params: { id: @ticket, ticket: { paid: false } }
    assert_redirected_to :tickets
  end

  test "should refund ticket" do
    assert_difference('Ticket.count', 0) do
      delete :destroy, params: { id: @ticket }
    end

    assert_redirected_to :tickets
  end

  test "should destroy free pass" do
    assert_difference('Ticket.count', -1) do
      delete :destroy, params: { id: tickets(:free_pass) }
    end

    assert_redirected_to :passes
  end

  test "should generate free pass link" do
    get :link, params: { free: true, show_id: shows(:next) }

    link = response.body.chomp
    assert_match %r(^https://weddingexpo\.co/account/tickets/redeem\?token=.+$), link

    token = CGI::parse(link.split('?').last)['token'][0]
    verifier = ActiveSupport::MessageVerifier.new(Rails.application.secrets[:public_site_secret_key])
    message = verifier.verify(token)
    assert_equal shows(:next).id, message
  end
end
