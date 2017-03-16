require 'rails_helper'

describe Comment, type: :model do
  ActiveRecord::Base.connection.create_table(:monkeys, force: true) do |t|
    t.string :name
    t.integer :comments_count
    t.timestamps null: false
  end

  class Monkey < ApplicationRecord
  end

  let(:monkey) { Monkey.create(name: "Foo") }
  let(:user) { create(:user) }

  describe 'create' do
    it 'should work' do
      comment = build(:comment, commentable: monkey)
      expect {
        comment.save
      }.to change(Comment, :count).by(1)
      monkey.reload
      expect(monkey.comments_count).to eq 1
    end

    it 'should mention' do
      body = "@#{user.login} 还好"
      comment = build(:comment, commentable: monkey, body: body)
      expect {
        comment.save
      }.to change(Notification, :count).by(1)
      note = user.notifications.last
      expect(note.notify_type).to eq('mention')
      expect(note.target_type).to eq('Comment')
      expect(note.target_id).to eq comment.id
      expect(note.second_target_type).to eq 'Monkey'
      expect(note.second_target_id).to eq monkey.id
    end
  end
end
