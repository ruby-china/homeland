class CreateTopics < ActiveRecord::Migration
  def self.up
    create_table :topics do |t|
      t.string :title, :null => false
      t.references :node, :null => false
      t.text :body, :null => false
      t.references :user, :null => false
      t.integer :replies_count, :null => false, :default => 0
      t.integer :last_reply_user_id
      t.datetime :replied_at
      t.string :source

      t.timestamps

    end

    add_index :topics, :node_id
    add_index :topics, :user_id
  end

  def self.down
    drop_table :topics
  end
end
