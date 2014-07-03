require 'rails_helper'

class TestDocument
  include Mongoid::Document
  include Mongoid::Mentionable

  belongs_to :user
  delegate :login, :to => :user, :prefix => true, :allow_nil => true
  field :body
end

describe Mongoid::Mentionable, :type => :model do
  it "should extract mentioned user ids" do
    user = Factory :user
    doc = TestDocument.create :body => "@#{user.login}", :user => Factory(:user)
    expect(doc.mentioned_user_ids).to eq([user.id])
    expect(doc.mentioned_user_logins).to eq([user.login])
  end

  it "limit 5 mentioned user" do
    logins = ""
    6.times { logins << " @#{Factory(:user).login}" }
    doc = TestDocument.create :body => logins, :user => Factory(:user)
    expect(doc.mentioned_user_ids.count).to eq(5)
  end

  it "except self user" do
    user = Factory :user
    doc = TestDocument.create :body => "@#{user.login}", :user => user
    expect(doc.mentioned_user_ids.count).to eq(0)
  end

  it "should get mentioned user logins" do
    user1 = Factory :user
    user2 = Factory :user
    doc = TestDocument.create :body => "@#{user1.login} @#{user2.login}", :user => Factory(:user)
    expect(doc.mentioned_user_logins).to match_array([user1.login, user2.login])
  end

  it "should send mention notification" do
    user = Factory :user
    expect do
      TestDocument.create :body => "@#{user.login}", :user => Factory(:user)
    end.to change(user.notifications.unread, :count)

    expect do
      TestDocument.create(:body => "@#{user.login}", :user => user)
    end.not_to change(user.notifications.unread, :count)

    expect do
      TestDocument.create(:body => "@#{user.login}", :user => Factory(:user)).destroy
    end.not_to change(user.notifications.unread, :count)
  end
end
