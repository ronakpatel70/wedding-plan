require 'test_helper'

class TestimonialTest < ActiveSupport::TestCase

  # Validations

  test 'should save valid testimonial' do
    testimonial = Testimonial.new(vendor: vendors(:one), quote: 'You are the best!', author: 'Average Joe')
    assert testimonial.save
  end

  test 'should not save without vendor' do
    testimonial = Testimonial.new(quote: 'You are the best!', author: 'Average Joe')
    assert_not testimonial.save
  end

  test 'should not save without quote' do
    testimonial = Testimonial.new(vendor: vendors(:one), author: 'Average Joe')
    assert_not testimonial.save
  end

end
