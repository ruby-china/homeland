require 'rails_helper'

ActiveRecord::Base.connection.create_table(:test_documents, force: true) do |t|
  t.integer :user_id
  t.integer :reply_to_id
  t.integer :mentioned_user_ids, array: true, default: []
  t.text :body
  t.timestamps null: false
end

class TestDocument < ApplicationRecord
  include Mentionable

  belongs_to :user
  belongs_to :reply_to, class_name: 'TestDocument'
  delegate :login, to: :user, prefix: true, allow_nil: true
end

describe Mentionable, type: :model do
  it 'should work with chars' do
    user = create :user, login: 'foo-bar_12'
    user1 = create :user, login: 'Rei.foo'
    doc = TestDocument.create body: "@#{user.login} @#{user1.login}", user: create(:user)
    expect(doc.mentioned_user_logins).to include(user.login, user1.login)

    doc = TestDocument.create body: "@#{user.login.upcase} @#{user1.login.downcase}", user: create(:user)
    expect(doc.mentioned_user_logins).to include(user.login, user1.login)
  end

  it 'should extract mentioned user ids' do
    user = create :user
    doc = TestDocument.create body: "@#{user.login}", user: create(:user)
    expect(doc.mentioned_user_ids).to eq([user.id])
    expect(doc.mentioned_user_logins).to eq([user.login])
  end

  it 'limit 5 mentioned user' do
    logins = ''
    6.times { logins << " @#{create(:user).login}" }
    doc = TestDocument.create body: logins, user: create(:user)
    expect(doc.mentioned_user_ids.count).to eq(5)
  end

  it 'except self user' do
    user = create :user
    doc = TestDocument.create body: "@#{user.login}", user: user
    expect(doc.mentioned_user_ids.count).to eq(0)
  end

  it 'should get mentioned user logins' do
    user1 = create :user
    user2 = create :user
    doc = TestDocument.create body: "@#{user1.login} @#{user2.login}", user: create(:user)
    expect(doc.mentioned_user_logins).to match_array([user1.login, user2.login])
  end

  it 'should send mention notification' do
    user = create :user
    expect do
      TestDocument.create body: "@#{user.login}", user: create(:user)
    end.to change(user.notifications.unread, :count)

    expect do
      TestDocument.create(body: "@#{user.login}", user: user)
    end.not_to change(user.notifications.unread, :count)

    expect do
      TestDocument.create(body: "@#{user.login}", user: create(:user)).destroy
    end.not_to change(user.notifications.unread, :count)
  end

  it 'should not mention Team' do
    team = create :team
    user1 = create :user
    doc = TestDocument.create body: "@#{team.login} @#{user1.login}", user: create(:user)
    doc.extract_mentioned_users
    assert_equal doc.mentioned_user_ids, [user1.id]

    expect do
      TestDocument.create body: "@#{team.login}", user: create(:user)
    end.to change(Notification, :count).by(0)
  end

  it 'should send mention to reply_to user' do
    user = create :user
    last_doc = TestDocument.create body: "@#{user.login}", user: user
    user1 = create :user
    expect do
      TestDocument.create body: "hello", reply_to_id: last_doc.id, user: user1
    end.to change(user.notifications.unread, :count)
  end

  describe '.send_mention_notification' do
    let(:actor) { create(:user) }
    let(:user1) { create(:user) }
    let(:doc) { TestDocument.create body: "@#{user1.login} Bla bla", user: actor }

    it 'should world' do
      expect(Notification).to receive(:realtime_push_to_client).exactly(2).times
      expect(PushJob).to receive(:perform_later).exactly(2).times
      expect do
        doc.send_mention_notification
      end.to change(user1.notifications.unread, :count)

      note = user1.notifications.unread.last
      expect(note.notify_type).to eq 'mention'
      expect(note.target_type).to eq 'TestDocument'
      expect(note.target_id).to eq doc.id
      expect(note.target.id).to eq doc.id
      expect(note.actor_id).to eq actor.id
    end
  end
end
