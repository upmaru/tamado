require "test_helper"

class ItemsControllerTest < ActionDispatch::IntegrationTest
  setup do
    sign_in users(:one)
  end

  test "creates a pending item through a project's list" do
    assert_difference "Item.count", 1 do
      post project_list_items_path(projects(:one), lists(:one)), params: { item: { description: "Schedule dentist appointment" } }, as: :turbo_stream
    end

    assert_response :success
    assert_equal "pending", Item.order(:created_at).last.current_state
    assert_match "Schedule dentist appointment", response.body
  end

  test "the created item is attributed to the signed-in user" do
    post project_list_items_path(projects(:one), lists(:one)), params: { item: { description: "Schedule dentist appointment" } }, as: :turbo_stream

    item = Item.find_by(description: "Schedule dentist appointment")
    assert_equal users(:one).id, item.creator_id
  end

  test "cannot create an item through another project's list" do
    post project_list_items_path(projects(:two), lists(:one)), params: { item: { description: "Schedule dentist appointment" } }, as: :turbo_stream

    assert_response :not_found
  end

  test "shows an item's audit trail with the creator and transition actor" do
    get item_path(items(:three))

    assert_response :success
    assert_select "h1", items(:three).description
    assert_select "h2", "Audit trail"
    assert_select "a", "+ Event"
    assert_select "p", /Created as/
    assert_select "span.badge-warning", "pending"
    assert_select "span.badge-success", "completed"
    assert_select "p", /by #{users(:one).email}/
  end

  test "shows an item's events" do
    get item_path(items(:one))

    assert_response :success
    assert_select "h2", "Events"
    assert_select "span.badge-ghost", "Due date"
    assert_select "time", items(:one).due_at.to_fs(:long)
  end

  test "another user's item audit trail is not found" do
    sign_in users(:two)
    get item_path(items(:one))

    assert_response :not_found
  end

  test "show is not found for a missing item" do
    get item_path("00000000-0000-0000-0000-000000000000")

    assert_response :not_found
  end

  test "does not duplicate an item's initial pending transition" do
    item = Item.create!(list: lists(:one), description: "Take out recycling", creator: users(:one))

    get item_path(item)

    assert_select "p", /Created as/
    assert_select "p", { text: /Changed from/, count: 0 }
  end

  test "completes a pending item and attributes the transition to the actor" do
    item = items(:one)

    assert_difference "Item::StateTransition.count", 1 do
      patch project_item_path(projects(:one), item)
    end

    assert_redirected_to project_path(projects(:one))
    assert item.reload.completed?
    assert_equal users(:one).id, item.state_transitions.order(:created_at).last.user_id
  end

  test "cannot update another user's item" do
    sign_in users(:two)
    patch project_item_path(projects(:one), items(:one))

    assert_response :not_found
  end
end
