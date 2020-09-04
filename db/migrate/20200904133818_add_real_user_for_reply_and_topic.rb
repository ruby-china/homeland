class AddRealUserForReplyAndTopic < ActiveRecord::Migration[6.0]
  def change
    add_column :replies, :real_user_id, :integer
    add_column :topics, :real_user_id, :integer
  end
end
