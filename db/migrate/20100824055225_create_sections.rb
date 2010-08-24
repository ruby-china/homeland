class CreateSections < ActiveRecord::Migration
  def self.up
    create_table :sections do |t|
      t.string :name, :null => false
      t.integer :sort, :null => false, :default => 0
    end

    add_index :sections, :sort
  end

  def self.down
    drop_table :sections
  end
end
