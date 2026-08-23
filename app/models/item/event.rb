class Item::Event < ApplicationRecord
  self.table_name = "item_events"

  KINDS = %w[ first_reminder second_reminder due_date ].freeze

  belongs_to :item

  validates :kind, inclusion: { in: KINDS }
  validate :require_at

  def at
    data&.dig("at")&.then { Time.zone.parse(_1) }
  end

  private

  def require_at
    errors.add(:base, "A date and time is required.") if data["at"].blank?
  end
end
