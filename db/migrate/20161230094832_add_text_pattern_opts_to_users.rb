class AddTextPatternOptsToUsers < ActiveRecord::Migration[5.0]
  def change
    # UPDATE users SET name = substring(name, 99) WHERE length(name) >= 100
    change_column :users, :login, :string, limit: 100
    change_column :users, :name, :string, limit: 100
    add_index :users, 'lower(login) varchar_pattern_ops'
    add_index :users, 'lower(name) varchar_pattern_ops'
  end
end
