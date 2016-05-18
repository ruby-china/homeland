class RemovePrivateTokenFromUsers < ActiveRecord::Migration[5.0]
  def change
    remove_column :users, :private_token
  end
end
