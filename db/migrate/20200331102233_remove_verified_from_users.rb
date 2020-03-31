# frozen_string_literal: true

class RemoveVerifiedFromUsers < ActiveRecord::Migration[6.0]
  def up
    remove_column :users, :verified
  end

  def down
    add_column :users, :verified, :boolean
  end
end
