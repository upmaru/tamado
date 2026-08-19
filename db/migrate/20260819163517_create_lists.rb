class CreateLists < ActiveRecord::Migration[8.1]
  def change
    create_table :lists, id: :uuid do |t|
      t.string :name
      t.references :project, null: false, foreign_key: true, type: :uuid

      t.timestamps
    end
  end
end
