class CreateCounters < ActiveRecord::Migration[7.0]
  def change
    create_table :counters do |t|
      t.references :countable, polymorphic: true
      t.string :key, null: false
      t.integer :value, null: false, default: 0
      t.timestamps
    end

    add_index :counters, [:countable_type, :countable_id, :key], unique: true
    add_index :counters, [:countable_type, :key, :value]
  end
end
