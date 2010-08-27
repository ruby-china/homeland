class CreateNotes < ActiveRecord::Migration
  def self.up
    create_table :notes do |t|
      t.string :title, :null => false
      t.text :body, :null => false
      t.references :user, :null => false
      t.integer :word_count, :null => false, :default => 0
      t.integer :changes_cout, :null => false, :default => 1

      t.timestamps
    end

    add_index :notes, :user_id
    add_column :users, :notes_count, :integer, :null => false, :default => 0
  end

  def self.down
    drop_table :notes
    remove_column :users, :notes_count
  end
end
