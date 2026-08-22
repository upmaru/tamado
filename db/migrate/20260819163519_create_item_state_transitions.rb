class CreateItemStateTransitions < ActiveRecord::Migration[8.1]
  def change
    create_table :item_state_transitions, id: :uuid do |t|
      t.references :item, null: false, foreign_key: true, type: :uuid
      t.string :namespace
      t.string :event
      t.string :from
      t.string :to
      t.timestamp :created_at
    end
  end
end
