class Item < ApplicationRecord
  acts_as_list scope: :list

  HASHTAG_REGEX = /#([\p{L}\p{N}_]+)/

  belongs_to :list
  belongs_to :creator, class_name: "User", inverse_of: :created_items
  has_many :state_transitions, class_name: "Item::StateTransition", dependent: :destroy
  has_many :events, class_name: "Item::Event", dependent: :destroy
  has_many :taggings, class_name: "Item::Tagging", dependent: :destroy
  has_many :tags, -> { order(:name) }, through: :taggings
  has_many_attached :attachments do |attachable|
    attachable.variant :thumb, resize_to_limit: [ 400, 400 ]
  end

  attr_accessor :actor

  validates :description, presence: true

  before_save :sync_tags

  state_machine :current_state, initial: :pending do
    audit_trail class: Item::StateTransition, context: :user_id, initial: false
    event :seen do
      transition pending: :seen
    end

    event :complete do
      transition pending: :completed, seen: :completed
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

  def sync_tags
    return if description.blank?

    names = description.scan(HASHTAG_REGEX).flatten.map { _1.downcase }.uniq
    return if names.empty?

    self.description = description_without_hashtags
    self.tags = tags_for_names(names)
  end

  def description_without_hashtags
    description.gsub(HASHTAG_REGEX, "").squish.presence || description
  end

  def tags_for_names(names)
    found = Tag.where(name: names).index_by(&:name)
    (names - found.keys).each do |name|
      found[name] = begin
        Tag.create!(name: name)
      rescue ActiveRecord::RecordNotUnique
        Tag.find_by!(name: name)
      end
    end
    found.values.sort_by(&:name)
  end

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
