class AddTeamIdToTopics < ActiveRecord::Migration[5.0]
  def change
    add_column :topics, :team_id, :integer
    add_index :topics, :team_id
  end
end
