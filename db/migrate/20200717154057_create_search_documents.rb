class CreateSearchDocuments < ActiveRecord::Migration[6.0]
  def change
    create_table :search_documents do |t|
      t.string :searchable_type, limit: 32, null: false
      t.integer :searchable_id, null: false
      t.tsvector :tokens
      t.text :content
      t.timestamps null: false
    end

    add_index :search_documents, [:searchable_type, :searchable_id], unique: true
    add_index :search_documents, :tokens, using: "gin"
  end
end
