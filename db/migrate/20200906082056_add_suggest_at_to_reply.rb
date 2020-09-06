class AddSuggestAtToReply < ActiveRecord::Migration[6.0]
  def change
    add_column :replies, :suggested_at, :datetime, default: nil
  end
end
