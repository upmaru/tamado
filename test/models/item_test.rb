require "test_helper"

class ItemTest < ActiveSupport::TestCase
  include ActiveJob::TestHelper

  test "new item defaults to pending state" do
    item = Item.new(list: lists(:one))

    assert_equal "pending", item.current_state
    assert item.pending?
    refute item.completed?
  end

  test "a new item requires a creator" do
    item = Item.new(list: lists(:one), description: "Buy milk")

    assert_not item.valid?
    assert item.errors[:creator].any?
  end

  test "an item requires a description" do
    item = Item.new(list: lists(:one), creator: users(:one))

    assert_not item.valid?
    assert item.errors[:description].any?
  end

  test "pending item can be completed" do
    item = items(:one)

    assert item.can_complete?
    item.actor = users(:one)
    item.complete!

    assert item.completed?
    assert_equal "completed", item.reload.current_state
  end

  test "pending item can be marked as seen" do
    item = items(:one)

    assert item.can_seen?
    item.actor = users(:one)
    item.seen!

    assert item.seen?
    refute item.completed?
    assert_equal "seen", item.reload.current_state
  end

  test "seen item cannot be marked as seen again" do
    item = items(:one)
    item.actor = users(:one)
    item.seen!

    assert_not item.can_seen?
    assert_raises(StateMachines::InvalidTransition) do
      item.seen!
    end
  end

  test "completed item cannot be marked as seen" do
    item = items(:one)
    item.actor = users(:one)
    item.complete!

    assert_raises(StateMachines::InvalidTransition) do
      item.seen!
    end
  end

  test "marking an item as seen records an audit trail transition attributed to the actor" do
    item = items(:one)
    ids_before = item.state_transitions.pluck(:id)

    item.actor = users(:one)
    item.seen!

    new_transitions = item.state_transitions.where.not(id: ids_before).to_a
    assert_equal 1, new_transitions.size
    assert_equal "seen", new_transitions.first.event
    assert_equal "pending", new_transitions.first.from
    assert_equal "seen", new_transitions.first.to
    assert_equal users(:one).id, new_transitions.first.user_id
  end

  test "a new item is appended to the end of its list" do
    item = Item.create!(list: lists(:one), description: "Buy flour", creator: users(:one))

    assert_equal 4, item.position
    assert_equal [ items(:one), items(:three), items(:four), item ].map(&:id), lists(:one).items.map(&:id)
  end

  test "item positions are scoped per list" do
    item = Item.create!(list: lists(:two), description: "Buy honey", creator: users(:two))

    assert_equal 2, item.position
    assert_equal 1, items(:two).reload.position
  end

  test "moving an item renumbers the rest of its list" do
    assert items(:four).move_higher

    assert_equal 1, items(:one).reload.position
    assert_equal 2, items(:four).reload.position
    assert_equal 3, items(:three).reload.position
  end

  test "destroying an item renumbers the rest of its list" do
    items(:one).destroy

    assert_equal 1, items(:three).reload.position
    assert_equal 2, items(:four).reload.position
    assert_equal 1, items(:two).reload.position
  end

  test "seen item can be completed" do
    item = items(:four)

    assert item.can_complete?
    item.actor = users(:one)
    item.complete!

    assert item.completed?
    assert_equal "completed", item.reload.current_state
  end

  test "completed item cannot be completed again" do
    item = items(:one)
    item.actor = users(:one)
    item.complete!

    assert_not item.can_complete?
    assert_raises(StateMachines::InvalidTransition) do
      item.complete!
    end
  end

  test "completing an item records an audit trail transition attributed to the actor" do
    item = items(:one)
    ids_before = item.state_transitions.pluck(:id)

    item.actor = users(:one)
    item.complete!

    new_transitions = item.state_transitions.where.not(id: ids_before).to_a
    assert_equal 1, new_transitions.size
    assert_equal "complete", new_transitions.first.event
    assert_equal "pending", new_transitions.first.from
    assert_equal "completed", new_transitions.first.to
    assert_equal users(:one).id, new_transitions.first.user_id
  end

  test "creating an item records a creation transition attributed to the creator" do
    item = Item.create!(list: lists(:one), description: "Buy milk", creator: users(:one))

    creation = item.state_transitions.order(:created_at).first
    assert_nil creation.event
    assert_nil creation.from
    assert_equal "pending", creation.to
    assert_equal users(:one).id, creation.user_id
  end

  test "destroying an item destroys its audit trail transitions" do
    assert_difference "Item::StateTransition.count", -1 do
      items(:three).destroy
    end
  end

  test "destroying an item destroys its events" do
    assert_difference "Item::Event.count", -1 do
      items(:one).destroy
    end
  end

  test "an item without due date events has no due date" do
    item = items(:two)

    assert_nil item.due_at
    refute item.overdue?
  end

  test "setting a due date records a due date event" do
    item = items(:two)

    item.due_at = Time.zone.parse("2026-09-01T09:00")

    event = Item.find(item.id).events.order(:created_at).last
    assert_equal "due_date", event.kind
    assert_equal Time.zone.parse("2026-09-01T09:00").iso8601, event.data["at"]
    assert_equal Time.zone.parse("2026-09-01T09:00"), Item.find(item.id).due_at
  end

  test "the latest due date event wins" do
    item = items(:two)
    item.due_at = Time.zone.parse("2026-08-20T09:00")
    item.due_at = Time.zone.parse("2026-09-01T09:00")

    assert_equal Time.zone.parse("2026-09-01T09:00"), Item.find(item.id).due_at
  end

  test "clearing a due date removes due date events" do
    item = items(:one)
    assert Item.find(item.id).due_at.present?

    assert_difference "Item::Event.count", -1 do
      item.due_at = nil
    end

    assert_nil Item.find(item.id).due_at
  end

  test "overdue? is true for a pending item past its due date" do
    item = items(:two)
    item.due_at = Time.current - 1.hour

    assert Item.find(item.id).overdue?
  end

  test "overdue? is false for a completed item past its due date" do
    item = items(:three)
    item.due_at = Time.current - 1.hour

    refute Item.find(item.id).overdue?
  end

  test "an item can have many attachments" do
    item = Item.create!(list: lists(:one), description: "Take out recycling", creator: users(:one))

    item.attachments.attach(sample_image("a.png"))
    item.attachments.attach(sample_image("b.png"))

    assert_equal 2, item.attachments.count
  end

  test "destroying an item purges its attachments" do
    item = Item.create!(list: lists(:one), description: "Take out recycling", creator: users(:one))
    item.attachments.attach(sample_image("a.png"))

    assert_difference "ActiveStorage::Attachment.count", -1 do
      perform_enqueued_jobs { item.destroy }
    end
  end

  def sample_image(filename)
    { io: File.open(Rails.root.join("test/fixtures/files/sample.png")), filename: filename, content_type: "image/png" }
  end
end
