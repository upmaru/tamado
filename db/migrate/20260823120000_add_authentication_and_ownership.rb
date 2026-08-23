class AddAuthenticationAndOwnership < ActiveRecord::Migration[8.1]
  def change
    create_table :users, id: :uuid do |t|
      t.string :email, null: false
      t.string :password_digest, null: false

      t.timestamps
    end
    add_index :users, :email, unique: true

    # The existing Home/Work seed data is disposable. Clear it before adding
    # NOT NULL owner references so the constraints can be applied cleanly.
    execute "TRUNCATE item_state_transitions, items, lists, projects CASCADE"

    change_table :projects do |t|
      t.references :user, null: false, type: :uuid, foreign_key: true
    end

    change_table :items do |t|
      t.references :creator, null: false, type: :uuid, foreign_key: { to_table: :users }
    end

    change_table :item_state_transitions do |t|
      t.references :user, null: false, type: :uuid, foreign_key: true
    end
  end
end
