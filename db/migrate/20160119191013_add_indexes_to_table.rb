class AddIndexesToTable < ActiveRecord::Migration[4.2]
  def change
    add_index :topics, :deleted_at
    add_index :topics, [:node_id, :deleted_at]

    add_index :replies, :deleted_at
    add_index :replies, [:topic_id, :deleted_at]

    add_index :sites, :deleted_at
    add_index :sites, [:site_node_id, :deleted_at]

    remove_index :users, :location
    add_index :users, :location

    add_index :nodes, :sort

    remove_index :pages, :slug
    add_index :pages, :slug, unique: true

    add_index :photos, :user_id
  end
end
