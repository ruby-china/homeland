class CreateProfiles < ActiveRecord::Migration[6.0]
  def change
    create_table :profiles do |t|
      t.integer :user_id, null: false
      t.jsonb :contacts, null: false, default: {}
      t.jsonb :rewards, null: false, default: {}
    end

    add_index :profiles, :user_id, unique: true
  end
end
