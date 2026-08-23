class Item::StateTransition < ApplicationRecord
  self.table_name = "item_state_transitions"

  belongs_to :item
  belongs_to :user
end
