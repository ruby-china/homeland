# frozen_string_literal: true

require "test_helper"

class MentionableTest < ActiveSupport::TestCase
  class TestDocument < ApplicationRecord
    include Mentionable

    belongs_to :user, optional: true
    belongs_to :reply_to, class_name: "TestDocument", optional: true
    delegate :login, to: :user, prefix: true, allow_nil: true
  end

  test "should work with chars" do
    user = create :user, login: "foo-bar_12"
    user1 = create :user, login: "Rei.foo"
    doc = TestDocument.create body: "@#{user.login} @#{user1.login}", user: create(:user)
    assert_includes doc.mentioned_user_logins, user.login
    assert_includes doc.mentioned_user_logins, user1.login

    doc = TestDocument.create body: "@#{user.login.upcase} @#{user1.login.downcase}", user: create(:user)
    assert_includes doc.mentioned_user_logins, user.login
    assert_includes doc.mentioned_user_logins, user1.login
  end

  test "should extract mentioned user ids" do
    user = create :user
    doc = TestDocument.create body: "@#{user.login}", user: create(:user)
    assert_equal [user.id], doc.mentioned_user_ids
    assert_equal [user.login], doc.mentioned_user_logins
  end

  test "limtest 5 mentioned user" do
    logins = []
    6.times { logins << "@#{create(:user).login}" }
    doc = TestDocument.create body: logins.join(" "), user: create(:user)
    assert_equal 5, doc.mentioned_user_ids.count
  end

  test "except self user" do
    user = create :user
    doc = TestDocument.create body: "@#{user.login}", user: user
    assert_equal 0, doc.mentioned_user_ids.count
  end

  test "should get mentioned user logins" do
    user1 = create :user
    user2 = create :user
    doc = TestDocument.create body: "@#{user1.login} @#{user2.login}", user: create(:user)
    assert_includes doc.mentioned_user_logins, user1.login
    assert_includes doc.mentioned_user_logins, user2.login
  end

  test "should send mention notification" do
    user = create :user
    assert_changes -> { user.notifications.unread.count } do
      TestDocument.create body: "@#{user.login}", user: create(:user)
    end

    assert_no_changes -> { user.notifications.unread.count } do
      TestDocument.create(body: "@#{user.login}", user: user)
    end

    assert_no_changes -> { user.notifications.unread.count } do
      TestDocument.create(body: "@#{user.login}", user: create(:user)).destroy
    end
  end

  test "should not mention Team" do
    team = create :team
    user1 = create :user
    doc = TestDocument.create body: "@#{team.login} @#{user1.login}", user: create(:user)
    doc.extract_mentioned_users
    assert_equal doc.mentioned_user_ids, [user1.id]

    assert_no_changes -> { Notification.count } do
      TestDocument.create body: "@#{team.login}", user: create(:user)
    end
  end

  test "should send mention to reply_to user" do
    user = create :user
    last_doc = TestDocument.create body: "@#{user.login}", user: user
    user1 = create :user

    assert_changes -> { user.notifications.unread.count } do
      TestDocument.create body: "hello", reply_to_id: last_doc.id, user: user1
    end
  end

  test ".send_mention_notification" do
    actor = create(:user)
    user = create(:user)
    doc = TestDocument.create(body: "@#{user.login} Bla bla", user: actor)

    Notification.expects(:realtime_push_to_client).once
    PushJob.expects(:perform_later).once

    assert_changes -> { user.notifications.unread.count } do
      doc.send(:send_mention_notification)
    end

    note = user.notifications.unread.last
    assert_equal "mention", note.notify_type
    assert_equal "MentionableTest::TestDocument", note.target_type
    assert_equal doc.id, note.target_id
    assert_equal doc.id, note.target.id
    assert_equal actor.id, note.actor_id
  end
end
