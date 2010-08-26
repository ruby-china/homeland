class CreatePhotos < ActiveRecord::Migration
  def self.up
    create_table :photos do |t|
      t.string :title, :null => false
      t.string :image_file_name, :null => false
      t.integer :image_file_size, :null => false, :default => 0
      t.integer :user_id

      t.timestamps
    end
  end

  def self.down
    drop_table :photos
  end
end
