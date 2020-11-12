class RenameLastActiveMarkToHotness < ActiveRecord::Migration[6.1]
  def change
    rename_column :topics, :last_active_mark, :score
    add_column :replies, :score, :integer, default: 0, null: false
  end
end
