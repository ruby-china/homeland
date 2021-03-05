# frozen_string_literal: true

class AddUniqueIndexToUsers < ActiveRecord::Migration[6.0]
  def up
    execute <<~SQL
      DELETE FROM users u WHERE u.id NOT IN (SELECT MIN(id) FROM users GROUP BY login)
    SQL
    execute <<~SQL
      DELETE FROM users u WHERE u.id NOT IN (SELECT MIN(id) FROM users GROUP BY email)
    SQL

    remove_index :users, :login
    remove_index :users, :email
    add_index :users, :login, unique: true
    add_index :users, :email, unique: true
  end

  def down
  end
end
