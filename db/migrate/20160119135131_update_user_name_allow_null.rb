class UpdateUserNameAllowNull < ActiveRecord::Migration
  def change
    change_column :users, :name, :string, null: true
  end
end
