class CommentablePage < ApplicationRecord
end

class Monkey < ApplicationRecord
end

def setup_test_db!
  ActiveRecord::Base.connection.create_table(:monkeys, force: true) do |t|
    t.string :name
    t.integer :user_id
    t.integer :comments_count
    t.timestamps null: false
  end

  ActiveRecord::Base.connection.create_table(:commentable_pages, force: true) do |t|
    t.string :name
    t.integer :user_id
    t.integer :comments_count, default: 0, null: false
    t.timestamps null: false
  end

  ActiveRecord::Base.connection.create_table(:test_documents, force: true) do |t|
    t.integer :user_id
    t.integer :reply_to_id
    t.integer :mentioned_user_ids, array: true, default: []
    t.text :body
    t.timestamps null: false
  end

  ActiveRecord::Base.connection.create_table(:walking_deads, force: true) do |t|
    t.string :name
    t.string :tag
    t.datetime :deleted_at
    t.timestamps null: false
  end
end
