class RemoveBodyHtmlField < ActiveRecord::Migration[5.0]
  def change
    remove_column :topics, :body_html
    remove_column :replies, :body_html
    remove_column :comments, :body_html
  end
end
