class OldSetting < ApplicationRecord
  self.table_name = "site_configs"
end

class CreateSettings < ActiveRecord::Migration[4.2]
  def self.up
    create_table :settings do |t|
      t.string :var, null: false
      t.text :value, null: true
      t.integer :thing_id, null: true
      t.string :thing_type, null: true, limit: 30
      t.timestamps
    end

    add_index :settings, %i[thing_type thing_id var], unique: true

    Setting.transaction do
      OldSetting.all.each do |item|
        Setting.create!(var: item.key, value: item.value)
      end
    end

    drop_table :site_configs
  end

  def self.down
    drop_table :settings
  end
end
