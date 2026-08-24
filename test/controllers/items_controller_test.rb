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

  test "creates an item tagged from hashtags in the description" do
    post project_list_items_path(projects(:one), lists(:one)), params: { item: { description: "Prepare the #demo deck" } }, as: :turbo_stream

    item = Item.order(:created_at).last
    assert_equal "Prepare the deck", item.description
    assert_equal [ "demo" ], item.tags.map(&:name)
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
    assert_select "a", "Edit"
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

  test "showing an item marks it as seen and attributes the transition to the viewer" do
    item = Item.create!(list: lists(:one), description: "Take out recycling", creator: users(:one))
    assert_equal "pending", item.current_state

    get item_path(item)

    assert_response :success
    assert item.reload.seen?
    transition = item.state_transitions.order(:created_at).last
    assert_equal "seen", transition.event
    assert_equal "pending", transition.from
    assert_equal "seen", transition.to
    assert_equal users(:one).id, transition.user_id
  end

  test "showing an already seen item does not record another transition" do
    item = items(:four)

    assert_no_difference "Item::StateTransition.count" do
      get item_path(item)
    end

    assert_response :success
  end

  test "showing an item does not duplicate its initial pending transition" do
    item = Item.create!(list: lists(:one), description: "Take out recycling", creator: users(:one))

    get item_path(item)

    assert_select "p", /Created as/
    assert_select "p", { text: /Changed from/, count: 1 }
    assert_select "p", { text: /Changed from pending to seen/, count: 1 }
  end

  test "shows a seen item's audit trail" do
    get item_path(items(:four))

    assert_response :success
    assert_select "h1", items(:four).description
    assert_select "span.badge-info", "seen"
    assert_select "p", { text: /Changed from pending to seen/, count: 1 }
  end

  test "shows the edit page with the current description" do
    get edit_item_path(items(:one))

    assert_response :success
    assert_select "h1", "Edit item"
    assert_select "input[name=?]", "item[description]"
    assert_select "input[value=?]", items(:one).description
  end

  test "updates an item's description and redirects to the item" do
    item = items(:one)

    patch item_path(item), params: { item: { description: "Buy oat milk" } }

    assert_redirected_to item_path(item)
    assert_equal "Buy oat milk", item.reload.description
  end

  test "updates an item's tags when its description hashtags change" do
    item = items(:one)

    patch item_path(item), params: { item: { description: "Buy oat milk for the #errands run" } }

    assert_redirected_to item_path(item)
    assert_equal [ "errands" ], item.reload.tags.map(&:name)
  end

  test "shows an item's tags" do
    item = Item.create!(list: lists(:one), description: "Prepare the #demo deck", creator: users(:one))

    get item_path(item)

    assert_response :success
    assert_select "a[href=?]", items_path(tag_ids: [ item.tags.first.id ])
    assert_select "a", "#demo"
    assert_select "a[href=?][data-turbo-method=?]", item_tagging_path(item, item.taggings.first), "delete"
  end

  test "lists only the signed-in user's items" do
    get items_path

    assert_response :success
    assert_select "a[href=?]", item_path(items(:one))
    assert_select "a[href=?]", item_path(items(:three))
    assert_select "a[href=?]", item_path(items(:four))
    assert_select "a[href=?]", item_path(items(:two)), count: 0
  end

  test "filters items by the tags they have" do
    get items_path(tag_ids: [ tags(:one).id ])

    assert_response :success
    assert_select "a[href=?]", item_path(items(:one))
    assert_select "a[href=?]", item_path(items(:three)), count: 0
    assert_select "a[href=?]", item_path(items(:four)), count: 0
  end

  test "matches any of several selected tags" do
    get items_path(tag_ids: [ tags(:one).id, tags(:two).id ])

    assert_response :success
    assert_select "a[href=?]", item_path(items(:one))
    assert_select "a[href=?]", item_path(items(:three))
    assert_select "a[href=?]", item_path(items(:four)), count: 0
  end

  test "shows an empty state for an unknown tag id" do
    get items_path(tag_ids: [ "00000000-0000-0000-0000-000000000000" ])

    assert_response :success
    assert_select "p", "No items match the selected tags."
  end

  test "offers a link to clear an active tag filter" do
    get items_path(tag_ids: [ tags(:one).id, tags(:two).id ])

    assert_response :success
    assert_select "a[href=?]", items_path(tag_ids: [ tags(:one).id ])
    assert_select "a[href=?]", items_path
  end

  test "re-renders the edit page when the description is blank" do
    item = items(:one)

    patch item_path(item), params: { item: { description: "" } }

    assert_response :unprocessable_entity
    assert_equal item.reload.description, "Buy milk"
  end

  test "cannot edit another user's item" do
    sign_in users(:two)

    get edit_item_path(items(:one))
    assert_response :not_found

    patch item_path(items(:one)), params: { item: { description: "Hijacked" } }
    assert_response :not_found
    assert_equal "Buy milk", items(:one).reload.description
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

  test "completes a seen item and attributes the transition to the actor" do
    item = items(:four)

    assert_difference "Item::StateTransition.count", 1 do
      patch project_item_path(projects(:one), item)
    end

    assert_redirected_to project_path(projects(:one))
    assert item.reload.completed?
    transition = item.state_transitions.order(:created_at).last
    assert_equal "complete", transition.event
    assert_equal "seen", transition.from
    assert_equal "completed", transition.to
    assert_equal users(:one).id, transition.user_id
  end

  test "cannot update another user's item" do
    sign_in users(:two)
    patch project_item_path(projects(:one), items(:one))

    assert_response :not_found
  end
end
