class CreateColumns < ActiveRecord::Migration[6.0]
  def change
    create_table :columns do |t|
      t.string :name
      t.text :description
      t.string :cover
      t.integer :user_id, null: false
      t.string :who_deleted
      t.integer :modified_admin_id
      t.integer :likes_count, default: 0
      t.datetime :suggested_at
      t.datetime :deleted_at
      t.string :slug, null: false
      t.datetime :unseal_time

      t.timestamps
    end

    add_index :columns, :name
    add_index :columns, :likes_count
    add_index :columns, :suggested_at

    add_column :users, :columns_count, :integer, default: 0
  end
end
