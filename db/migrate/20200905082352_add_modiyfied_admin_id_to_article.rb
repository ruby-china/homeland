class AddModiyfiedAdminIdToArticle < ActiveRecord::Migration[6.0]
  def change
    add_column :topics, :modified_admin_id, :integer
  end
end
