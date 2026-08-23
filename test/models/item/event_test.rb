require "test_helper"

class Item::EventTest < ActiveSupport::TestCase
  test "an event belongs to an item" do
    assert_equal items(:one), item_events(:one).item
  end

  test "an event requires a known kind" do
    event = Item::Event.new(item: items(:one), kind: "unknown")

    assert_not event.valid?
    assert event.errors[:kind].any?
  end

  test "an event stores its date and time as data" do
    assert_equal "2027-08-25T09:00:00.000Z", item_events(:one).data["at"]
  end

  test "an event exposes its date and time as a Time" do
    assert_equal Time.zone.parse("2027-08-25T09:00:00.000Z"), item_events(:one).at
  end

  test "an event requires a date and time" do
    event = Item::Event.new(item: items(:one), kind: "due_date")

    assert_not event.valid?
    assert event.errors[:base].any?
  end
end
