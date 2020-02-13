# frozen_string_literal: true

class UpgradeUserState < ActiveRecord::Migration[6.0]
  def up
    # vip: 3, admin: 99
    execute <<-SQL
      UPDATE users SET state = 3 WHERE verified = true
    SQL
  end

  def down
  end
end
