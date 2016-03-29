class RemoveOldNotifications < ActiveRecord::Migration[5.0]
  def change
    drop_table :notifications
  end
end
