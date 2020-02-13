# frozen_string_literal: true

class UpgradeUserState < ActiveRecord::Migration[6.0]
  def up
    # vip: 3, admin: 99
    execute <<-SQL
      UPDATE users SET state = 3 WHERE verified = true
    SQL
    admin_user_ids = User.where(email: Setting.admin_emails).pluck(:id)
    if admin_user_ids.any?
      execute <<-SQL
        UPDATE users SET state = 99 WHERE id IN (#{admin_user_ids.join(",")})
      SQL
    end
  end

  def down
  end
end
