class CreateCounters < ActiveRecord::Migration
  def self.up
    create_table :counters do |t|
      t.string :key, :null => false
      t.string :value, :null => false
    end

    add_index :counters, :key
  end

  def self.down
    drop_table :counters
  end
end
