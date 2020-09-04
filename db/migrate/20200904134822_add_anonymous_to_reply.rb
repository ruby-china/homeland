class AddAnonymousToReply < ActiveRecord::Migration[6.0]
  def change
    add_column :replies, :anonymous, :integer, default: 0, null: false
  end
end
