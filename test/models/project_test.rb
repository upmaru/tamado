require "test_helper"

class ProjectTest < ActiveSupport::TestCase
  test "a project has many lists" do
    assert_equal [lists(:one)], projects(:one).lists
  end

  test "a project has many items through its lists" do
    assert_equal [items(:one), items(:three)].map(&:id).sort, projects(:one).items.map(&:id).sort
  end

  test "destroying a project destroys its lists and their items" do
    assert_difference "List.count", -1 do
      assert_difference "Item.count", -2 do
        projects(:one).destroy
      end
    end
  end
end
