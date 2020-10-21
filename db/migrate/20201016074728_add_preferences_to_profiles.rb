class AddPreferencesToProfiles < ActiveRecord::Migration[6.0]
  def change
    add_column :profiles, :preferences, :jsonb, default: {}, null: false
  end
end
