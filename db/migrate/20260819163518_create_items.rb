class CreateItems < ActiveRecord::Migration[8.1]
  def change
    create_table :items, id: :uuid do |t|
      t.text :description
      t.references :list, null: false, foreign_key: true, type: :uuid
      t.string :current_state

      t.timestamps
    end
  end
end
