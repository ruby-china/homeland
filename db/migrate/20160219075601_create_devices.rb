class CreateDevices < ActiveRecord::Migration[5.0]
  def change
    create_table :devices do |t|
      t.integer :platform, null: false
      t.integer :user_id, null: false
      t.string :token, null: false
      t.datetime :last_actived_at

      t.timestamps
    end

    add_index :devices, :user_id
    add_index :devices, [:user_id, :platform]
  end
end
