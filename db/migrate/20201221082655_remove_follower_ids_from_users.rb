class RemoveFollowerIdsFromUsers < ActiveRecord::Migration[6.1]
  def change
    # Remove unused Array fields, they were instead by ActionStore
    # ref: https://github.com/ruby-china/homeland/pull/857
    remove_column :users, :follower_ids
  end
end
