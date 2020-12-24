class RemoveSection < ActiveRecord::Migration[6.1]
  def change
    drop_table :sections
    remove_column :nodes, :section_id
  end
end
