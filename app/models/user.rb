class User < ApplicationRecord
  EMAIL_REGEX = /\A[\w.+-]+@[\w-]+\.[\w.-]+\z/

  has_secure_password

  has_many :projects, dependent: :destroy
  has_many :created_items, class_name: "Item", foreign_key: :creator_id, inverse_of: :creator
  has_many :state_transitions, class_name: "Item::StateTransition"

  normalizes :email, with: ->(email) { email.strip.downcase }

  validates :email, presence: true, uniqueness: { case_sensitive: false }, format: { with: EMAIL_REGEX }
  validates :password, presence: true
end
