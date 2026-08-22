require "test_helper"

class ItemsControllerTest < ActionDispatch::IntegrationTest
  test "creates a pending item through a project's list" do
    assert_difference "Item.count", 1 do
      post project_list_items_path(projects(:one), lists(:one)), params: { item: { description: "Schedule dentist appointment" } }, as: :turbo_stream
    end

    assert_response :success
    assert_equal "pending", Item.order(:created_at).last.current_state
    assert_match "Schedule dentist appointment", response.body
  end

  test "cannot create an item through another project's list" do
    post project_list_items_path(projects(:two), lists(:one)), params: { item: { description: "Schedule dentist appointment" } }, as: :turbo_stream

    assert_response :not_found
  end

  test "shows an item's audit trail" do
    get item_path(items(:three))

    assert_response :success
    assert_select "h1", items(:three).description
    assert_select "h2", "Audit trail"
    assert_select "p", /Created as/
    assert_select "span.badge-warning", "pending"
    assert_select "span.badge-success", "completed"
  end

  test "show is not found for a missing item" do
    get item_path("00000000-0000-0000-0000-000000000000")

    assert_response :not_found
  end

  test "does not duplicate an item's initial pending transition" do
    item = Item.create!(list: lists(:one), description: "Take out recycling")

    get item_path(item)

    assert_select "p", /Created as/
    assert_select "p", { text: /Changed from/, count: 0 }
  end

  test "completes a pending item" do
    item = items(:one)

    assert_difference "ItemStateTransition.count", 1 do
      patch project_item_path(projects(:one), item)
    end

    assert_redirected_to project_path(projects(:one))
    assert item.reload.completed?
  end

  test "cannot update an item through another project" do
    patch project_item_path(projects(:two), items(:one))

    assert_response :not_found
  end
end
