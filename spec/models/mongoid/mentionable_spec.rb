require 'rails_helper'

class TestDocument
  include Mongoid::Document
  include Mongoid::Mentionable

  belongs_to :user
  delegate :login, to: :user, prefix: true, allow_nil: true
  field :body
end

describe Mongoid::Mentionable, type: :model do
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
end
