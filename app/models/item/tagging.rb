class Item::Tagging < ApplicationRecord
  self.table_name = "item_taggings"

  belongs_to :tag
  belongs_to :item
end
