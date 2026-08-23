class Item < ApplicationRecord
  belongs_to :list
  belongs_to :creator, class_name: "User", inverse_of: :created_items
  has_many :state_transitions, class_name: "Item::StateTransition", dependent: :destroy
  has_many :events, class_name: "Item::Event", dependent: :destroy

  attr_accessor :actor

  state_machine :current_state, initial: :pending do
    audit_trail class: Item::StateTransition, context: :user_id, initial: false
    event :complete do
      transition pending: :completed
    end
  end

  after_create :record_creation_transition

  def user_id
    actor&.id
  end

  def due_at
    @due_at ||= latest_due_date_event&.at
  end

  def due_at=(value)
    if value.nil?
      events.where(kind: "due_date").destroy_all
      @due_at = nil
      return
    end

    @due_at = value
    events.create!(kind: "due_date", data: { "at" => value.iso8601 })
  end

  def overdue?
    due_at.present? && !completed? && due_at < Time.current
  end

  private

  def latest_due_date_event
    events.where(kind: "due_date").order(created_at: :desc, id: :desc).first
  end

  def record_creation_transition
    state_transitions.create!(
      namespace: "current_state",
      event: nil,
      from: nil,
      to: current_state,
      user_id: creator_id
    )
  end
end
