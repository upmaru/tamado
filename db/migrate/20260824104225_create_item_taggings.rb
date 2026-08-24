class CreateItemTaggings < ActiveRecord::Migration[8.1]
  def change
    create_table :item_taggings, id: :uuid do |t|
      t.references :tag, null: false, type: :uuid, foreign_key: { on_delete: :cascade }
      t.references :item, null: false, type: :uuid, foreign_key: { on_delete: :cascade }

      t.timestamps
    end

    add_index :item_taggings, %i[tag_id item_id], unique: true
  end
end
