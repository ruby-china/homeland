class RemoveUnneededIndexes < ActiveRecord::Migration[5.0]
  def change
    remove_index :devices, name: "index_devices_on_user_id_and_platform"
    remove_index :page_versions, name: "index_page_versions_on_page_id_and_version"
    remove_index :replies, name: "index_replies_on_topic_id_and_deleted_at"
    remove_index :team_users, name: "index_team_users_on_team_id_and_user_id"
    remove_index :topics, name: "index_topics_on_node_id"
    remove_index :new_notifications, name: "index_new_notifications_on_user_id_and_notify_type"
  end
end
