require 'test_helper'

class BoothTest < ActiveSupport::TestCase

  setup do
    @vendor = vendors(:one)
    @show = shows(:one)
  end

  # Callbacks

  test 'should mark vendor as sold on create' do
    booth = Booth.create(show: @show, vendor: @vendor, size: '6x6', payment_method: 'card')

    assert_equal 'sold', @vendor.show_statuses[@show.id.to_s]
  end

  test 'should destroy booth' do
    booth = booths(:two)
    payments = booth.payments

    assert_difference('Payment.scheduled.count', -1) do
      booth.destroy
    end

    assert booth.destroyed?
    assert booth.fees.empty?
    assert booth.payments.empty?
    assert booth.coordinate.destroyed?
  end

  test 'should attach sign when approving' do
    booth = Booth.create!(show: @show, vendor: @vendor, size: '3x6')
    booth.add_ons.create!(type: 'sign')
    booth.approved!

    assert_equal ['sign'], booth.add_ons.pluck(:type)
    assert_equal signs(:one), booth.sign
  end

  test 'should send welcome text when checking in' do
    stub_request(:post, SMS_URL).to_return(:body => File.open("test/stubs/sms.json"))

    booth = booths(:one)
    booth.checked_in_at = Time.now

    assert_difference('Text.count') do
      assert booth.save
    end
  end

  test 'should not send welcome message to vendor without cell phone' do
    booth = booths(:no_amenities)
    booth.checked_in_at = Time.now

    assert_difference('Text.count', 0) do
      assert booth.save
    end
  end

  # Validations

  test 'should save valid booth' do
    booth = Booth.new(show: @show, vendor: @vendor, size: '6x6', industries: ['cake'], payment_method: 'card')
    assert booth.save
  end

  test 'should not save invalid size' do
    booth = Booth.new(show: @show, vendor: @vendor, size: '13x11')
    assert_not booth.save
  end

  test 'should not save without payment_method' do
    booth = Booth.new(show: @show, vendor: @vendor, size: '13x11', payment_method: nil)
    assert_not booth.save
  end

  test 'should not save without vendor' do
    booth = Booth.new(show: @show, size: '6x6', industries: ['cake'], payment_method: 'card')
    assert_not booth.save
  end

  test 'should not save without show' do
    booth = Booth.new(vendor: @vendor, size: '6x6', industries: ['cake'], payment_method: 'card')
    assert_not booth.save
  end

  test 'should not save with photography industry' do
    booth = Booth.new(show: @show, vendor: @vendor, size: '6x6', payment_method: 'card', industries: ['photography'])
    assert_not booth.save
  end

  test 'should not save with duplicate industry' do
    booth = Booth.new(show: @show, vendor: @vendor, size: '6x6', payment_method: 'card', industries: ['apparel'])
    assert_not booth.save
    assert booth.errors.include?(:industries)
  end

  test 'should not save invalid add-on' do
    booth = Booth.new(show: @show, vendor: @vendor, size: '6x6', payment_method: 'card')
    booth.add_ons << AddOn.new(type: 'invalid')
    assert_not booth.save
    assert booth.errors.include?(:add_ons)
  end

  # Scopes

  test 'flagged should include booths with flagged = true' do
    assert_equal 1, Booth.flagged.count
  end

  test 'visible should include booths with visible = true' do
    assert_equal 2, Booth.visible.count
  end

  test 'with_bag should include booths with bag add-on' do
    assert_equal 2, Booth.with_bag.count
  end

  test 'with_industries should include booths with industry add-ons' do
    assert_equal 1, Booth.with_industries.count
  end

  test 'with_sign should include booths with sign add-on' do
    assert_equal 1, Booth.with_sign.count
  end

  test 'with_size should include booths where size is not nil' do
    assert_equal 3, Booth.with_size.count
    assert_equal 2, Booth.without_size.count
  end

  # Methods

  test 'to_s should return size and show date' do
    assert_equal '3x6 Booth - Oct \'14', booths(:no_amenities).to_s
    assert_equal 'Bag Promo - Oct \'14', booths(:bag_only).to_s
    assert_equal 'Empty Application - Oct \'14', booths(:nothing).to_s
  end

  test 'bag_promo? should return presence of bag add-on' do
    assert booths(:one).bag_promo?
    assert_not booths(:two).bag_promo?
    assert_not booths(:no_amenities).bag_promo?
  end

  test 'calculate_total should set correct total on save' do
    booth = Booth.new(show: @show, vendor: @vendor, size: '6x6', industries: ['cake'])
    assert booth.save

    booth.add_ons = AddOn.generate('power', 'labels', 'vehicles')
    assert booth.save
    assert_equal 126500, booth.total # 750 + 350 + 25 + 40 + 100
  end

  test 'door should return correct door number' do
    assert_equal 'B', booths(:one).door
  end

  test 'line_items should include booth size, amenities and industries' do
    items = booths(:two).line_items
    assert_equal({type: 'booth', title: 'Deluxe Booth', price: 85000}, items[0])
    assert_equal({type: 'add_on', title: 'Power', price: 2500, quantity: 1}, items[1])
    assert_equal({type: 'industry', title: 'Extra Industry (Dj)', price: 35000}, items[2])
  end

  test 'payment deadline should be 30 days before show' do
    assert_equal booths(:one).created_at.to_date + 30.days, booths(:one).payment_deadline
    assert_equal shows(:two).date - 30.days, booths(:two).payment_deadline
  end

  test 'total and balance should be updated on save' do
    booth = booths(:one)
    booth.update(size: '6x8')
    assert_equal 106500, booth.total
    assert_equal 86500, booth.balance

    booth.update(industries: ['dj'])
    assert_equal 141500, booth.total
    assert_equal 121500, booth.balance
  end

end
