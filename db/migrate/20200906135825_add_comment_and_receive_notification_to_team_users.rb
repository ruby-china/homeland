class AddCommentAndReceiveNotificationToTeamUsers < ActiveRecord::Migration[6.0]
  def change
    add_column :team_users, :comment, :text
    add_column :team_users, :is_receive_notifications, :boolean, default: true, null: false
  end
end
