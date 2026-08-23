require "test_helper"

class UserTest < ActiveSupport::TestCase
  test "a user is valid with an email and password" do
    user = User.new(email: "new@example.com", password: "password123", password_confirmation: "password123")

    assert user.valid?
  end

  test "email is required" do
    user = User.new(email: nil, password: "password123", password_confirmation: "password123")

    assert_not user.valid?
    assert user.errors[:email].any?
  end

  test "email is normalized and must be unique" do
    duplicate = User.new(email: "ONE@example.com", password: "password123", password_confirmation: "password123")

    assert_equal "one@example.com", duplicate.email
    assert_not duplicate.valid?
    assert duplicate.errors[:email].any?
  end

  test "email must be a valid format" do
    user = User.new(email: "not-an-email", password: "password123", password_confirmation: "password123")

    assert_not user.valid?
    assert user.errors[:email].any?
  end

  test "password must be confirmed" do
    user = User.new(email: "new@example.com", password: "password123", password_confirmation: "nope")

    assert_not user.valid?
    assert user.errors[:password_confirmation].any?
  end

  test "authenticates with the correct password and rejects the wrong one" do
    user = users(:one)

    assert user.authenticate("password123")
    refute user.authenticate("wrong-password")
  end

  test "a user has many projects" do
    assert_equal [ projects(:one) ], users(:one).projects
  end

  test "a user has many created items" do
    assert_equal [ items(:one), items(:three) ].map(&:id).sort, users(:one).created_items.map(&:id).sort
  end

  test "a user has many item state transitions" do
    assert_includes users(:one).state_transitions, item_state_transitions(:one)
  end
end
