require "test_helper"

class Item::StateTransitionTest < ActiveSupport::TestCase
  test "a transition belongs to an item" do
    assert_equal items(:three), item_state_transitions(:one).item
  end
end
