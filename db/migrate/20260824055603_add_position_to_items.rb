class AddPositionToItems < ActiveRecord::Migration[8.1]
  def up
    add_column :items, :position, :integer

    execute <<~SQL
      UPDATE items
      SET position = numbered.rnk
      FROM (
        SELECT id, ROW_NUMBER() OVER (PARTITION BY list_id ORDER BY created_at, id) AS rnk
        FROM items
      ) AS numbered
      WHERE items.id = numbered.id
    SQL

    change_column_null :items, :position, false
  end

  def down
    remove_column :items, :position
  end
end
