class RemoveHrFields < ActiveRecord::Migration[5.0]
  def change
    remove_column :users, :hr
  end
end
