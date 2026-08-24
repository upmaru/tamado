require "test_helper"

class TagTest < ActiveSupport::TestCase
  test "name is normalized to lowercase" do
    tag = Tag.new(name: " Work ")

    assert_equal "work", tag.name
  end

  test "a tag requires a name" do
    tag = Tag.new

    assert_not tag.valid?
    assert tag.errors[:name].any?
  end

  test "tag names must be unique" do
    duplicate = Tag.new(name: "work")

    assert_not duplicate.valid?
    assert duplicate.errors[:name].any?
  end

  test "tag names are unique case-insensitively" do
    duplicate = Tag.new(name: "WORK")

    assert_equal "work", duplicate.name
    assert_not duplicate.valid?
    assert duplicate.errors[:name].any?
  end

  test "a tag can be linked to many items" do
    assert_equal [ items(:one) ], tags(:one).items
    assert_equal [ items(:three) ], tags(:two).items
  end
end
