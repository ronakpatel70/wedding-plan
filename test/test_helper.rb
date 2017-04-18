ENV['RAILS_ENV'] ||= 'test'
require File.expand_path('../../config/environment', __FILE__)
require 'rails/test_help'
require 'webmock/minitest'
Dir[Rails.root.join("test/support/**/*")].each { |f| require f }

CU_URL = "https://api.stripe.com/v1/customers/cus_79ZU2mLycWhs6c"
RCP_URL = "https://api.stripe.com/v1/recipients/rp_000000"
SUB_URL = "https://api.stripe.com/v1/subscriptions/sub_83JcItwbPyAcvJ"
PAY_SUB_URL = "https://api.stripe.com/v1/invoices/in_99999/pay"
CU_INVOICE_URL = "https://api.stripe.com/v1/invoices?closed=false&customer=cus_79ZU2mLycWhs6c"
PY_URL = "https://api.stripe.com/v1/charges"
SMS_URL = "https://api.twilio.com/2010-04-01/Accounts/not_used/Messages.json"

class ActiveSupport::TestCase
  ActiveRecord::Migration.maintain_test_schema!

  # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
  fixtures :all

  # Add more helper methods to be used by all tests here...
  WebMock.disable_net_connect!(allow_localhost: true)
end
