require "test_helper"

class Item::TaggingsControllerTest < ActionDispatch::IntegrationTest
  setup do
    sign_in users(:one)
  end

  test "the item page links each tag to the filtered items page" do
    get item_path(items(:one))

    assert_response :success
    assert_select "a[href=?]", items_path(tag_ids: [ tags(:one).id ])
    assert_select "a", "#work"
  end

  test "the item page offers a remove control for each tag" do
    get item_path(items(:one))

    assert_response :success
    assert_select "a[href=?][data-turbo-method=?]", item_tagging_path(items(:one), item_taggings(:one)), "delete"
  end

  test "removing a tagging unlinks the tag but keeps the tag" do
    item = items(:one)

    assert_difference "Item::Tagging.count", -1 do
      assert_no_difference "Tag.count" do
        delete item_tagging_path(item, item_taggings(:one))
      end
    end

    assert_redirected_to item_path(item)
    assert item.reload.tags.empty?
    assert Tag.exists?(name: "work")
  end

  test "cannot remove a tagging from another user's item" do
    sign_in users(:two)

    assert_no_difference "Item::Tagging.count" do
      delete item_tagging_path(items(:one), item_taggings(:one))
    end

    assert_response :not_found
  end

  test "cannot remove a tagging that belongs to another item" do
    other_tagging = item_taggings(:two)

    assert_no_difference "Item::Tagging.count" do
      delete item_tagging_path(items(:one), other_tagging)
    end

    assert_response :not_found
    assert Item::Tagging.exists?(other_tagging.id)
  end
end
