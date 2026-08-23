class CreateItemEvents < ActiveRecord::Migration[8.1]
  def change
    create_table :item_events, id: :uuid do |t|
      t.references :item, null: false, type: :uuid, foreign_key: { on_delete: :cascade }
      t.string :kind, null: false
      t.jsonb :data, null: false, default: {}
      t.timestamps
    end

    add_index :item_events, %i[item_id kind created_at]
  end
end
