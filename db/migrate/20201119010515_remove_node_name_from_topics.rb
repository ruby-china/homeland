class RemoveNodeNameFromTopics < ActiveRecord::Migration[6.1]
  def change
    remove_column :topics, :node_name
  end
end
