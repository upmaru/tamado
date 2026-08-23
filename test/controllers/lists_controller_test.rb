require "test_helper"

class ListsControllerTest < ActionDispatch::IntegrationTest
  setup do
    sign_in users(:one)
  end

  test "new displays the new list form" do
    get new_project_list_path(projects(:one))

    assert_response :success
    assert_select "h1", "New list"
    assert_select "form[action=?]", project_lists_path(projects(:one))
    assert_select "input[name='list[name]'][required]"
    assert_select "a[href=?]", project_path(projects(:one)), text: "Cancel"
  end

  test "create adds a list and redirects to the project" do
    assert_difference "List.count", 1 do
      post project_lists_path(projects(:one)), params: { list: { name: "New List" } }
    end

    assert_redirected_to project_path(projects(:one))
  end

  test "cannot open a new list for another user's project" do
    sign_in users(:two)
    get new_project_list_path(projects(:one))

    assert_response :not_found
  end

  test "new is not found for a missing project" do
    get new_project_list_path("00000000-0000-0000-0000-000000000000")

    assert_response :not_found
  end
end
