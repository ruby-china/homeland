class CreateUserSSO < ActiveRecord::Migration[5.0]
  def change
    create_table :user_ssos do |t|
      t.integer :user_id, null: false
      t.string :uid, null: false, length: 255
      t.string :username
      t.string :email
      t.string :name
      t.string :avatar_url
      t.text :last_payload, null: false
      t.timestamps
    end

    add_index :user_ssos, :uid, unique: true
  end
end
