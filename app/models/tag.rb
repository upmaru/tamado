class Tag < ApplicationRecord
  has_many :taggings, class_name: "Item::Tagging", dependent: :destroy
  has_many :items, through: :taggings

  normalizes :name, with: ->(name) { name.strip.downcase }

  validates :name, presence: true, uniqueness: true
end
