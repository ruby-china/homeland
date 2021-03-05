class MigrateProfileData < ActiveRecord::Migration[6.0]
  disable_ddl_transaction!

  def up
    say_with_time "Migration profile_fields..." do
      Setting.unscoped.where(thing_type: "User", var: "profile_fields").find_each do |setting|
        Profile.upsert({contacts: setting.value, user_id: setting.thing_id}, unique_by: :user_id)
      end
    end

    say_with_time "Migration reward_fields..." do
      Setting.unscoped.where(thing_type: "User", var: "reward_fields").find_each do |setting|
        Profile.upsert({rewards: setting.value, user_id: setting.thing_id}, unique_by: :user_id)
      end
    end
  end

  def down
  end
end
