require 'rails_helper'

describe Comment, type: :model do
  let(:monkey) { Monkey.create(name: "Foo") }
  let(:user) { create(:user) }

  describe 'base' do
    it 'should work' do
      comment = Comment.new
      expect(comment.respond_to?(:mentioned_user_ids)).to eq true
      expect(comment.respond_to?(:extract_mentioned_users)).to eq true
    end
  end

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

    describe 'Base notify for commentable' do
      let(:monkey_user) { create('user') }
      let(:monkey) { Monkey.create(name: "Bar", user_id: monkey_user.id) }

      it 'should notify commentable creator' do
        comment = build(:comment, commentable: monkey, body: "Hello")
        expect {
          comment.save
        }.to change(Notification, :count).by(1)
        note = monkey_user.notifications.last
        expect(note.notify_type).to eq('comment')
        expect(note.target_type).to eq('Comment')
        expect(note.target_id).to eq comment.id
        expect(note.second_target_type).to eq 'Monkey'
        expect(note.second_target_id).to eq monkey.id
      end

      it 'should only once notify when have mention' do
        comment = build(:comment, commentable: monkey, body: "Hello @#{monkey_user.login}")
        expect {
          comment.save
        }.to change(Notification, :count).by(1)
        note = monkey_user.notifications.last
        expect(note.notify_type).to eq('mention')
        expect(note.target_type).to eq('Comment')
        expect(note.target_id).to eq comment.id
        expect(note.second_target_type).to eq 'Monkey'
        expect(note.second_target_id).to eq monkey.id
      end
    end
  end
end
