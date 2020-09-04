class AddDraftToTopic < ActiveRecord::Migration[6.0]
  def change
    add_column :topics, :draft, :boolean, default: true, null: false
  end
end
