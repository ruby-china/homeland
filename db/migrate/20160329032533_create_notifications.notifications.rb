# This migration comes from notifications (originally 20160328045436)
class CreateNotifications < ActiveRecord::Migration[4.2]
  def change
    create_table :new_notifications do |t|
      t.integer :user_id, null: false
      t.integer :actor_id
      t.string :notify_type, null: false
      t.string :target_type
      t.integer :target_id
      t.string :second_target_type
      t.integer :second_target_id
      t.string :third_target_type
      t.integer :third_target_id
      t.datetime :read_at

      t.timestamps null: false
    end

    add_index :new_notifications, [:user_id, :notify_type]
    add_index :new_notifications, [:user_id]
  end
end
