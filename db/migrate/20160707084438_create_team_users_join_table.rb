class CreateTeamUsersJoinTable < ActiveRecord::Migration[5.0]
  def change
    add_column :users, :type, :string, limit: 20, after: :id

    create_table(:team_users) do |t|
      t.integer :team_id, index: true, null: false
      t.integer :user_id, index: true, null: false
      t.integer :role
      t.integer :status

      t.timestamps null: false
    end

    add_index :team_users, [:team_id, :user_id], unique: true
  end
end
