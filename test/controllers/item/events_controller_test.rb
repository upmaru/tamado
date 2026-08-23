require "test_helper"

class Item::EventsControllerTest < ActionDispatch::IntegrationTest
  setup do
    sign_in users(:one)
  end

  test "shows the new event form" do
    get new_item_event_path(items(:one))

    assert_response :success
    assert_select "h1", "New event"
    assert_select "select[name=?]", "event[kind]"
    assert_select "input[name=?]", "event[at]"
  end

  test "creating a due date event redirects to the item" do
    item = items(:one)

    assert_difference "Item::Event.count", 1 do
      post item_events_path(item), params: { event: { kind: "due_date", at: "2027-09-01T09:00" } }
    end

    assert_redirected_to item_path(item)
    assert_equal Time.zone.parse("2027-09-01T09:00"), Item.find(item.id).due_at
  end

  test "creating a due date event without a date re-renders the form" do
    item = items(:one)

    assert_no_difference "Item::Event.count" do
      post item_events_path(item), params: { event: { kind: "due_date", at: "" } }
    end

    assert_response :unprocessable_entity
    assert_select "h1", "New event"
  end

  test "creating an event with an unknown kind re-renders the form" do
    assert_no_difference "Item::Event.count" do
      post item_events_path(items(:one)), params: { event: { kind: "note", at: "2027-09-01T09:00" } }
    end

    assert_response :unprocessable_entity
  end

  test "events for another user's item are not found" do
    sign_in users(:two)

    get new_item_event_path(items(:one))
    assert_response :not_found

    assert_no_difference "Item::Event.count" do
      post item_events_path(items(:one)), params: { event: { kind: "due_date", at: "2027-09-01T09:00" } }
    end
    assert_response :not_found
  end

  test "events for a missing item are not found" do
    get new_item_event_path("00000000-0000-0000-0000-000000000000")

    assert_response :not_found
  end
end
