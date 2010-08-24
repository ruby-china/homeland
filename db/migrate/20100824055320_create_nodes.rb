class CreateNodes < ActiveRecord::Migration
  def self.up
    create_table :nodes do |t|
      t.string :name, :null => false
      t.references :section, :null => false
      t.integer :sort, :null => false, :default => 0
      t.integer :topics_count, :null => false, :default => 0
      t.string :summary

    end
    add_index :nodes, :section_id
  end

  def self.down
    drop_table :nodes
  end
end
