class RemoveBadFieldsFromUsers < ActiveRecord::Migration[5.0]
  def change
    remove_column :users, :co
    remove_column :users, :qq
  end
end
