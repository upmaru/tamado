class Project < ApplicationRecord
  has_many :lists, dependent: :destroy
  has_many :items, through: :lists
end
