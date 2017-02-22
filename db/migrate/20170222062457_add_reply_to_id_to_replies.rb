class AddReplyToIdToReplies < ActiveRecord::Migration[5.0]
  def change
    add_column :replies, :reply_to_id, :integer
  end
end
