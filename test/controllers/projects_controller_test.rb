require "test_helper"

class ProjectsControllerTest < ActionDispatch::IntegrationTest
  test "index lists all projects" do
    get root_path

    assert_response :success
    assert_select "h1", "Projects"
    assert_select "a[href=?]", project_path(projects(:one))
    assert_select "a[href=?]", project_path(projects(:two))
  end

  test "show displays a project and links to its lists" do
    get project_path(projects(:one))

    assert_response :success
    assert_select "h1", projects(:one).name
    assert_select "a[href=?]", project_list_path(projects(:one), lists(:one))
  end

  test "show is not found for a missing project" do
    get project_path("00000000-0000-0000-0000-000000000000")

    assert_response :not_found
  end

  test "the sidebar lists every project and highlights the active one" do
    get project_path(projects(:one))

    assert_select "nav.menu a[href=?]", project_path(projects(:two))
    assert_select "nav.menu a.active[href=?]", project_path(projects(:one))
    assert_select "nav.menu a.active[href=?]", 0, project_path(projects(:two))
  end

  test "the layout links the compiled tailwind stylesheet and it is served" do
    get root_path

    match = response.body.match(%r{href="(/assets/tailwind[^"]+\.css)"})
    assert match, "expected a link to the compiled tailwind stylesheet"

    get match[1]
    assert_response :success
    assert_match "daisyUI", response.body
  end
end
