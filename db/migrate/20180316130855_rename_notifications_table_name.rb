class RenameNotificationsTableName < ActiveRecord::Migration[5.2]
  def change
    # Revert Notification table name to "notifications"
    rename_table :new_notifications, :notifications
  end
end
