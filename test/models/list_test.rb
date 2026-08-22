require "test_helper"

class ListTest < ActiveSupport::TestCase
  test "a list belongs to a project" do
    assert_equal projects(:one), lists(:one).project
  end

  test "a list has many items" do
    assert_equal [items(:one), items(:three)].map(&:id).sort, lists(:one).items.map(&:id).sort
  end

  test "destroying a list destroys its items" do
    assert_difference "Item.count", -2 do
      lists(:one).destroy
    end
  end
end
