class RemoveArrayActionFields < ActiveRecord::Migration[5.0]
  def change
    # Remove old Array fields, they were instead by ActionStore
    # ref: https://github.com/ruby-china/homeland/pull/857
    remove_column :users, :following_ids
    remove_column :users, :blocked_user_ids
    remove_column :users, :blocked_node_ids
    remove_column :users, :favorite_topic_ids

    remove_column :topics, :liked_user_ids
    remove_column :topics, :follower_ids

    remove_column :replies, :liked_user_ids
  end
end
