require 'test_helper'

class LocationTest < ActiveSupport::TestCase

  # Validations

  test 'should save valid location' do
    location = Location.new name: 'Los Angeles', handle: 'los-angeles', address: addresses(:wfc)
    assert location.save
  end

  test 'should not save missing name' do
    location = Location.new name: nil, handle: 'los-angeles', address: addresses(:wfc)
    assert_not location.save
  end

  test 'should not save invalid handle' do
    location = Location.new name: 'Los Angeles', handle: '', address: addresses(:wfc)
    assert_not location.save

    location = Location.new name: 'Los Angeles', handle: 'los-', address: addresses(:wfc)
    assert_not location.save

    location = Location.new name: 'Los Angeles', handle: '9-times', address: addresses(:wfc)
    assert_not location.save

    location = Location.new name: 'Los Angeles', handle: 'santa_rosa', address: addresses(:wfc)
    assert_not location.save
  end

  test 'should not save duplicate handle' do
    location = Location.new name: 'Los Angeles', handle: 'santa-rosa', address: addresses(:wfc)
    assert_not location.save
  end

  test 'should not save missing address' do
    location = Location.new name: 'Los Angeles', handle: 'los-angeles', address: nil
    assert_not location.save
  end

  # Methods

  test 'to_s should return name' do
    assert_equal 'Santa Rosa', locations(:sr).to_s
  end

end
