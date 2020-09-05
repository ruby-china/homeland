class AddFollowersCountToColumn < ActiveRecord::Migration[6.0]
  def change
    add_column :columns, :followers_count, :integer, default: 0
  end
end
