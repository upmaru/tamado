require "test_helper"

class Item::AttachmentsControllerTest < ActionDispatch::IntegrationTest
  setup do
    sign_in users(:one)
  end

  test "the item page offers a file dropzone" do
    get item_path(items(:one))

    assert_response :success
    assert_select "[data-controller=?]", "dropzone"
    assert_select "input[type='file'][name=?]", "item[attachments][]"
  end

  test "the item page shows image thumbnails and file-type icons" do
    item = items(:one)
    item.attachments.attach(fixture_file_upload("sample.png", "image/png"))
    item.attachments.attach(fixture_file_upload("notes.txt", "text/plain"))

    get item_path(item)

    assert_response :success
    assert_select "img"
    assert_select "li span", "notes.txt"
  end

  test "attaching a file adds it to the item" do
    item = items(:one)

    assert_difference "ActiveStorage::Attachment.count", 1 do
      post item_attachments_path(item), params: { item: { attachments: [ fixture_file_upload("sample.png", "image/png") ] } }
    end

    assert_redirected_to item_path(item)
    assert_equal 1, item.reload.attachments.count
  end

  test "removing a file purges it" do
    item = items(:one)
    item.attachments.attach(fixture_file_upload("sample.png", "image/png"))
    attachment = item.attachments.first

    assert_difference "ActiveStorage::Attachment.count", -1 do
      delete item_attachment_path(item, attachment)
    end

    assert_redirected_to item_path(item)
    assert_equal 0, item.reload.attachments.count
  end

  test "cannot attach a file to another user's item" do
    sign_in users(:two)

    assert_no_difference "ActiveStorage::Attachment.count" do
      post item_attachments_path(items(:one)), params: { item: { attachments: [ fixture_file_upload("sample.png", "image/png") ] } }
    end

    assert_response :not_found
  end

  test "cannot remove a file from another user's item" do
    item = items(:one)
    item.attachments.attach(fixture_file_upload("sample.png", "image/png"))
    attachment = item.attachments.first

    sign_in users(:two)

    assert_no_difference "ActiveStorage::Attachment.count" do
      delete item_attachment_path(item, attachment)
    end

    assert_response :not_found
    assert_equal 1, item.reload.attachments.count
  end
end
