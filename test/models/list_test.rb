require "test_helper"

class ListTest < ActiveSupport::TestCase
  test "a list belongs to a project" do
    assert_equal projects(:one), lists(:one).project
  end

  test "a list has many items" do
    assert_equal [ items(:one), items(:three), items(:four) ].map(&:id).sort, lists(:one).items.map(&:id).sort
  end

  test "destroying a list destroys its items" do
    assert_difference "Item.count", -3 do
      assert_difference "Item::StateTransition.count", -2 do
        assert_difference "Item::Event.count", -1 do
          lists(:one).destroy
        end
      end
    end
  end
end
