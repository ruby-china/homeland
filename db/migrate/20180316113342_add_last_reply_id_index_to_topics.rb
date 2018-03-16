class AddLastReplyIdIndexToTopics < ActiveRecord::Migration[5.2]
  def change
    add_index :topics, :last_reply_id
  end
end
