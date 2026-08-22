class List < ApplicationRecord
  belongs_to :project
  has_many :items, -> { order(:created_at) }, dependent: :destroy
end
