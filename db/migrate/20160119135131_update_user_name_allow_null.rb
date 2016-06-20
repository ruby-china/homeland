class UpdateUserNameAllowNull < ActiveRecord::Migration[4.2]
  def change
    change_column :users, :name, :string, null: true
  end
end
