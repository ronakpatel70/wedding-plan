require 'test_helper'

class AddOnTest < ActiveSupport::TestCase

  # Validations

  test 'should create valid add-on' do
    add_on = AddOn.new(type: 'power', booth: booths(:one))
    assert add_on.save
    assert_equal 2500, add_on.price
    assert_equal 2500, add_on.total

    add_on = AddOn.new(type: 'vehicles', quantity: 3, booth: booths(:one))
    assert add_on.save
    assert_equal 10000, add_on.price
    assert_equal 30000, add_on.total
  end

  test 'should not save without type' do
    add_on = AddOn.new(type: nil, booth: booths(:one))
    assert_not add_on.save
  end

  test 'should not save without booth' do
    add_on = AddOn.new(type: 'power', booth: nil)
    assert_not add_on.save
  end

  test 'should not save with negative price' do
    add_on = AddOn.new(type: 'tables', quantity: 1, price: -100, booth: booths(:one))
    assert_not add_on.save
  end

  # Callbacks

  test 'should update booth total when created' do
    booth = Booth.create(vendor: vendors(:one), show: shows(:one), size: '6x6')
    assert_difference('booth.total', 4000) do
      AddOn.create!(type: 'labels', booth: booth)
    end
  end

  test 'should update booth total when destroyed' do
    booth = Booth.create!(vendor: vendors(:one), show: shows(:one), size: '6x6')
    add_on = AddOn.create!(booth: booth, type: 'labels')
    assert_difference('booth.total', -4000) do
      add_on.destroy!
    end
  end

  test 'should use regular price when created on booth without size' do
    booth = booths(:nothing)
    assert_difference('booth.total', 75000) do
      add_on = AddOn.create!(booth: booth, type: 'bag_promo')
      assert_equal add_on.price, 75000
    end
  end

  test 'should use combo price when created on booth with size' do
    booth = booths(:no_amenities)
    assert_difference('booth.total', 25000) do
      add_on = AddOn.create!(booth: booth, type: 'bag_promo')
      assert_equal add_on.price, 25000
    end
  end

  test 'should set default value' do
    booth = booths(:two)
    add_on = AddOn.new(booth: booth, type: :tables)

    assert add_on.save
    assert_equal "8'", add_on.value

    booth = booths(:no_amenities)
    add_on = AddOn.new(booth: booth, type: :tables)

    assert add_on.save
    assert_equal nil, add_on.value
  end

  test 'should not set default value without booth size' do
    booth = booths(:nothing)
    add_on = AddOn.new(booth: booth, type: :tables)

    assert add_on.save
    assert_equal nil, add_on.value
  end

  # Methods

  test 'has_add_on? should return true if add_on exists' do
    assert booths(:one).has_add_on?('power')
    assert booths(:two).has_add_on?('beverage', 'beer')
    assert_not booths(:one).has_add_on?('linen')
    assert_not booths(:two).has_add_on?('beverage', 'wine')
  end

end
