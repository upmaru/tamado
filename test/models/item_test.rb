require "test_helper"

class ItemTest < ActiveSupport::TestCase
  test "new item defaults to pending state" do
    item = Item.new(list: lists(:one))

    assert_equal "pending", item.current_state
    assert item.pending?
    refute item.completed?
  end

  test "pending item can be completed" do
    item = items(:one)

    assert item.can_complete?
    item.complete!

    assert item.completed?
    assert_equal "completed", item.reload.current_state
  end

  test "completed item cannot be completed again" do
    item = items(:one)
    item.complete!

    assert_not item.can_complete?
    assert_raises(StateMachines::InvalidTransition) do
      item.complete!
    end
  end

  test "completing an item records an audit trail transition" do
    item = items(:one)
    ids_before = item.item_state_transitions.pluck(:id)

    item.complete!

    new_transitions = item.item_state_transitions.where.not(id: ids_before).to_a
    assert_equal 1, new_transitions.size
    assert_equal "complete", new_transitions.first.event
    assert_equal "pending", new_transitions.first.from
    assert_equal "completed", new_transitions.first.to
  end

  test "destroying an item destroys its audit trail transitions" do
    assert_difference "ItemStateTransition.count", -1 do
      items(:three).destroy
    end
  end
end
