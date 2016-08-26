class AddLevelToOauthApplications < ActiveRecord::Migration[5.0]
  def change
    add_column :oauth_applications, :level, :integer, default: 0, null: false
  end
end
