class AddCascadeDeleteToItemStateTransitions < ActiveRecord::Migration[8.1]
  def change
    remove_foreign_key :item_state_transitions, :items
    add_foreign_key :item_state_transitions, :items, on_delete: :cascade
  end
end
