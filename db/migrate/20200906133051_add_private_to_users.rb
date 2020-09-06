class AddPrivateToUsers < ActiveRecord::Migration[6.0]
  def change
    add_column :users, :private, :boolean, default: false, null: false
  end
end
