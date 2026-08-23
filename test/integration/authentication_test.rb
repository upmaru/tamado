require "test_helper"

class AuthenticationTest < ActionDispatch::IntegrationTest
  test "a guest is redirected to the login page from a protected route" do
    get projects_path

    assert_redirected_to new_auth_session_path
  end

  test "the login page renders for a guest" do
    get new_auth_session_path

    assert_response :success
    assert_select "h1", "Log in"
    assert_select "form[action=?]", auth_sessions_path
  end

  test "the signup page renders for a guest" do
    get new_auth_registration_path

    assert_response :success
    assert_select "h1", "Sign up"
    assert_select "form[action=?]", auth_registrations_path
  end

  test "a signed-in user is not shown the login page" do
    sign_in users(:one)
    get new_auth_session_path

    assert_redirected_to projects_path
  end

  test "a user can sign up and is signed in" do
    assert_difference "User.count", 1 do
      post auth_registrations_path, params: { user: { email: "new@example.com", password: "password123", password_confirmation: "password123" } }
    end

    assert_redirected_to projects_path
    follow_redirect!
    assert_response :success
    assert_select "h1", "Projects"
  end

  test "signing up with an invalid account does not create a user" do
    assert_no_difference "User.count" do
      post auth_registrations_path, params: { user: { email: "one@example.com", password: "password123", password_confirmation: "mismatch" } }
    end

    assert_response :unprocessable_entity
  end

  test "a user can log in with valid credentials" do
    post auth_sessions_path, params: { session: { email: "one@example.com", password: "password123" } }

    assert_redirected_to projects_path
    follow_redirect!
    assert_response :success
    assert_select "h1", "Projects"
  end

  test "a user cannot log in with invalid credentials" do
    post auth_sessions_path, params: { session: { email: "one@example.com", password: "wrong-password" } }

    assert_response :unprocessable_entity
    assert_match "Invalid email or password.", response.body
  end

  test "a signed-in user can log out" do
    sign_in users(:one)
    delete auth_logout_path

    assert_redirected_to new_auth_session_path

    get projects_path
    assert_redirected_to new_auth_session_path
  end
end
