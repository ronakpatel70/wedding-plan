require 'test_helper'

class ArticleTest < ActiveSupport::TestCase

  # Validations

  test 'should save valid article' do
    article = Article.new(page: 'staff_handbook', title: 'Article 2', content: 'Content.', order: 2)
    assert article.save
  end

  test 'should not save duplicate order' do
    article = Article.new(page: 'staff_handbook', title: 'Article 1', order: 1)
    assert_not article.save
  end

  test 'should not save without title' do
    article = Article.new(page: 'staff_handbook', title: nil, order: 3)
    assert_not article.save
  end

  test 'should not save long title' do
    article = Article.new(page: 'staff_handbook', title: '01234567890123456789012345678901234567890123456789-', order: 2)
    assert_not article.save
  end

  # Scopes

  test 'default scope should order by order field' do
    assert_equal [0, 1, 3, 4], Article.all.pluck(:order)
  end

end
