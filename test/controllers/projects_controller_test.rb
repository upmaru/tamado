require "test_helper"

class ProjectsControllerTest < ActionDispatch::IntegrationTest
  test "index lists all projects" do
    get projects_path

    assert_response :success
    assert_select "h1", "Projects"
    assert_select "a[href=?]", project_path(projects(:one))
    assert_select "a[href=?]", project_path(projects(:two))
  end

  test "root redirects to projects" do
    get root_path

    assert_redirected_to projects_path
  end

  test "show displays a project's lists and nested items" do
    get project_path(projects(:one))

    assert_response :success
    assert_select "h1", projects(:one).name
    assert_select "h2", lists(:one).name
    assert_select "a", items(:one).description
    assert_select "span.badge-warning", text: "pending"
    assert_select "span.badge-success", text: "completed"
    assert_select "input.checkbox[type=checkbox]", count: 2
    assert_select "a[href=?]", item_path(items(:one)), text: items(:one).description
    assert_select "form[action=?]", project_list_items_path(projects(:one), lists(:one))
    assert_select "button[data-action='new-item#show']", "+ Item"
    assert_select "form[hidden][action=?]", project_list_items_path(projects(:one), lists(:one))
  end

  test "show is not found for a missing project" do
    get project_path("00000000-0000-0000-0000-000000000000")

    assert_response :not_found
  end

  test "the layout uses the bumblebee theme without a sidebar" do
    get projects_path

    assert_select "html[data-theme=bumblebee]"
    assert_select "aside", count: 0
    assert_select "main.mx-auto.max-w-3xl"
  end
end
