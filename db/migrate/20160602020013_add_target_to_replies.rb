class AddTargetToReplies < ActiveRecord::Migration[5.0]
  def change
    add_column :replies, :action, :string
    add_column :replies, :target_type, :string, after: :action
    add_column :replies, :target_id, :string, after: :target_type
  end
end
