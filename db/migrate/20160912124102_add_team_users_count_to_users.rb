class AddTeamUsersCountToUsers < ActiveRecord::Migration[5.0]
  def up
    add_column :users, :team_users_count, :integer

    User.reset_column_information
    say_with_time "Reset all teams' team_users counter cache" do
      Team.select(:id).find_each { |team| Team.reset_counters(team.id, :team_users) }
    end
  end

  def down
    remove_column :users, :team_users_count
  end
end
