class CreateAuthorizations < ActiveRecord::Migration
  def self.up
    create_table :authorizations do |t|
      t.string :provider, :null => false
      t.string :uid, :null => false, :limit => 1000
      t.references :user, :null => false

      t.timestamps
    end

		add_index :authorizations, [:provider, :uid]
  end

  def self.down
    drop_table :authorizations
  end
end
