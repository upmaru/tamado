class Project < ApplicationRecord
  belongs_to :user
  has_many :lists, dependent: :destroy
  has_many :items, through: :lists
end
