require "test_helper"

class ProjectsControllerTest < ActionDispatch::IntegrationTest
  setup do
    sign_in users(:one)
  end

  test "index lists only the signed-in user's projects" do
    get projects_path

    assert_response :success
    assert_select "h1", "Projects"
    assert_select "a[href=?]", project_path(projects(:one))
    assert_select "a[href=?]", project_path(projects(:two)), count: 0
  end

  test "index links to the new project page" do
    get projects_path

    assert_select "a[href=?]", new_project_path, text: "+ Project"
  end

  test "new displays the new project form" do
    get new_project_path

    assert_response :success
    assert_select "h1", "New project"
    assert_select "form[action=?]", projects_path
    assert_select "input[name='project[name]'][required]"
    assert_select "a[href=?]", projects_path, text: "Cancel"
  end

  test "create adds a project owned by the signed-in user and redirects to index" do
    assert_difference "Project.count", 1 do
      post projects_path, params: { project: { name: "New Project" } }
    end

    assert_redirected_to projects_path
    assert_equal users(:one).id, Project.order(:created_at).last.user_id
  end

  test "create adds a project for turbo_stream requests" do
    assert_difference "Project.count", 1 do
      post projects_path, params: { project: { name: "New Project" } }, as: :turbo_stream
    end

    assert_redirected_to projects_path
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
    assert_select "span.badge-info", text: "seen"
    assert_select "span.badge-success", text: "completed"
    assert_select "input.checkbox[type=checkbox]", count: 3
    assert_select "span.tooltip[data-tip=Seen]", count: 1
    assert_select "button[data-reorder-target=handle]", count: 3
    assert_select "ul[data-controller=reorder]", count: 1
    assert_select "a[href=?]", item_path(items(:one)), text: items(:one).description
    assert_select "form[action=?]", project_list_items_path(projects(:one), lists(:one))
    assert_select "button[data-action='new-item#show']", "+ Item"
    assert_select "a[href=?]", new_project_list_path(projects(:one)), text: "+ List"
    assert_select "form[hidden][action=?]", project_list_items_path(projects(:one), lists(:one))
  end

  test "another user's project is not found" do
    sign_in users(:two)
    get project_path(projects(:one))

    assert_response :not_found
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
