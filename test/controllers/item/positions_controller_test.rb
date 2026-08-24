require "test_helper"

class Item::PositionsControllerTest < ActionDispatch::IntegrationTest
  setup do
    sign_in users(:one)
  end

  test "update changes an item's position within the list" do
    list = lists(:one)

    patch project_list_position_path(projects(:one), list), params: { ids: [ items(:three).id, items(:four).id, items(:one).id ] }, as: :json

    assert_response :ok
    assert_equal [ items(:three), items(:four), items(:one) ].map(&:id), list.items.map(&:id)
    assert_equal 3, items(:one).reload.position
    assert_equal 1, items(:three).reload.position
  end

  test "update is not found when an id is not in the list" do
    list = lists(:one)
    positions_before = list.items.pluck(:id, :position)

    patch project_list_position_path(projects(:one), list), params: { ids: [ items(:two).id, items(:one).id ] }, as: :json

    assert_response :not_found
    assert_equal positions_before, list.items.pluck(:id, :position)
  end

  test "cannot update positions in another user's list" do
    sign_in users(:two)

    patch project_list_position_path(projects(:one), lists(:one)), params: { ids: [ items(:three).id, items(:four).id, items(:one).id ] }, as: :json

    assert_response :not_found
  end
end
