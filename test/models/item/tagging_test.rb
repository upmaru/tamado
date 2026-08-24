require "test_helper"

class Item::TaggingTest < ActiveSupport::TestCase
  test "a tagging requires a tag and an item" do
    tagging = Item::Tagging.new

    assert_not tagging.valid?
    assert tagging.errors[:tag].any?
    assert tagging.errors[:item].any?
  end

  test "a tag has many taggings" do
    assert_equal [ item_taggings(:one) ], tags(:one).taggings
  end
end
