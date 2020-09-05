class AddArticleResource < ActiveRecord::Migration[6.0]
  def change
    add_column :topics, :type, :string
    add_column :columns, :articles_count, :integer, default: 0, null: false
    add_column :topics, :article_public, :boolean, default: true , null: false
    add_column :topics, :column_id, :integer
  end
end
