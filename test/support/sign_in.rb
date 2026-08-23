# Test helper for establishing an authenticated session in integration tests.
# Logs in through the real login endpoint. All fixture users
# (see test/fixtures/users.yml) share this password.
module SignIn
  TEST_PASSWORD = "password123"

  def sign_in(user)
    post auth_sessions_path, params: { session: { email: user.email, password: TEST_PASSWORD } }
    raise "Failed to sign in as #{user.email}" unless response.redirect?
  end
end
