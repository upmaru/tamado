require "test_helper"

class ListsControllerTest < ActionDispatch::IntegrationTest
  test "show displays the list items with state badges" do
    get project_list_path(projects(:one), lists(:one))

    assert_response :success
    assert_select "h1", lists(:one).name
    assert_select "span.badge-warning", text: "pending"
    assert_select "span.badge-success", text: "completed"
  end

  test "completed items are struck through" do
    get project_list_path(projects(:one), lists(:one))

    assert_select "span.line-through", text: items(:three).description
    assert_select "span.line-through", text: items(:one).description, count: 0
  end

  test "show is scoped to the parent project" do
    get project_list_path(projects(:one), lists(:two))

    assert_response :not_found
  end
end
