# frozen_string_literal: true

require "test_helper"

class TopicTest < ActiveSupport::TestCase
  attr_accessor :topic, :user

  setup do
    @topic = create(:topic)
    @user = create(:user)
  end

  test "should no save invalid node_id" do
    refute_equal true, build(:topic, node_id: nil).valid?
  end

  test "should set last_active_mark on created" do
    # because the Topic index is sort by replied_at,
    # so the new Topic need to set a Time, that test will display in index page
    refute_nil create(:topic).last_active_mark
  end

  test "should not update last_active_mark on save" do
    last_active_mark_was = topic.last_active_mark
    topic.save
    assert_equal last_active_mark_was, topic.last_active_mark
  end

  test "should update after reply" do
    reply = create :reply, topic: topic, user: user
    refute_nil topic.last_active_mark
    assert_equal reply.created_at.to_i, topic.replied_at.to_i
    assert_equal reply.id, topic.last_reply_id
    assert_equal reply.user_id, topic.last_reply_user_id
    assert_equal reply.user.login, topic.last_reply_user_login
  end

  test "should update after reply without last_active_mark when the topic is created at month ago" do
    topic.stubs(:created_at).returns(1.month.ago)
    topic.stubs(:last_active_mark).returns(1)
    reply = create :reply, topic: topic, user: user
    refute_equal reply.created_at.to_i, topic.last_active_mark
    assert_equal reply.user_id, topic.last_reply_user_id
    assert_equal reply.user.login, topic.last_reply_user_login
  end

  test "should not update last_active_mark when update reply" do
    reply = create :reply, topic: topic, user: user
    old_last_active_mark = topic.last_active_mark
    reply.body = "foobar"
    reply.save
    assert_equal old_last_active_mark, topic.last_active_mark
  end

  test "should get page and floor by reply" do
    replies = []
    5.times do
      replies << create(:reply, topic: topic, user: user)
    end
    assert_equal 3, topic.floor_of_reply(replies[2])
    assert_equal 4, topic.floor_of_reply(replies[3])
  end

  test "should log deleted user name when use destroy_by" do
    topic.destroy_by(user)
    assert_equal user.login, topic.who_deleted
    refute_equal nil, topic.deleted_at
    topic1 = create(:topic)
    assert_equal false, topic1.destroy_by(nil)
  end

  test "#auto_space_with_en_zh should auto fix on save" do
    topic.title = "Gitlab怎么集成GitlabCI"
    topic.save
    topic.reload
    assert_equal "Gitlab 怎么集成 GitlabCI", topic.title
  end

  test "#excellent should suggest a topic as excellent" do
    topic.excellent!
    topic.save
    assert_includes Topic.excellent, topic
  end

  test ".update_last_reply should work" do
    old_updated_at = topic.updated_at
    r = create(:reply, topic: topic)
    assert_equal true, topic.update_last_reply(r)
    assert_equal r.created_at, topic.replied_at
    assert_equal r.id, topic.last_reply_id
    assert_equal r.user_id, topic.last_reply_user_id
    assert_equal r.user.login, topic.last_reply_user_login
    refute_nil topic.last_active_mark
    refute_equal old_updated_at, topic.updated_at
  end

  test ".update_last_reply should update with nil when have :force" do
    topic.update_last_reply(nil, force: true)
    assert_nil topic.replied_at
    assert_nil topic.last_reply_id
    assert_nil topic.last_reply_user_id
    assert_nil topic.last_reply_user_login
    refute_nil topic.last_active_mark
  end

  test ".update_deleted_last_reply when have last Reply and param test that Reply" do
    t = topic
    r0 = create(:reply, topic: t)
    create(:reply, action: "foo")
    r1 = create(:reply, topic: t)
    assert_equal r1.id, t.last_reply_id

    t.expects(:update_last_reply).with(r0, force: true).once
    t.update_deleted_last_reply(r1)
  end

  test "update_deleted_last_reply last reply will be nil" do
    t = topic
    r = create(:reply, topic: t)
    assert_equal true, t.update_deleted_last_reply(r)
    t.reload
    assert_nil t.last_reply_id
    assert_nil t.last_reply_user_login
    assert_nil t.last_reply_user_id
  end

  test ".update_deleted_last_reply when param is nil" do
    t = topic
    assert_equal false, t.update_deleted_last_reply(nil)

    # when last reply is not equal param
    r0 = create(:reply, topic: t)
    r1 = create(:reply, topic: t)
    assert_equal false, t.update_deleted_last_reply(r0)
    assert_equal r1.id, t.last_reply_id
  end

  test ".ban!" do
    topic.ban!
    topic.reload
    assert_equal true, topic.ban?
  end

  test ".ban! with reason" do
    admin = create(:admin)
    Current.stubs(:user).returns(admin)
    topic.ban!(reason: "Block this topic")
    topic.reload
    assert_equal true, topic.ban?
    r = topic.replies.last
    assert_equal "ban", r.action
    assert_equal "Block this topic", r.body
  end

  test ".reply_ids" do
    replies = create_list(:reply, 10, topic: topic)

    assert_equal replies.collect(&:id), topic.reply_ids
  end

  test ".close! / .open! / closed?" do
    topic.close!
    assert_equal true, topic.closed?
    topic.open!
    assert_nil topic.closed_at
    assert_equal false, topic.closed?
    topic.close!
  end

  test ".excellent! / .unexcellent!" do
    create(:admin)
    topic = create(:topic, user: user)

    Current.stubs(:user).returns(user)
    assert_changes -> { Reply.where(action: "excellent", user: user).count }, 1 do
      topic.excellent!
    end
    assert_equal true, topic.excellent?

    assert_changes -> { Reply.where(action: "unexcellent", user: user).count }, 1 do
      topic.unexcellent!
    end
    assert_equal false, topic.excellent?
  end

  test ".indexed_changed? with title changed" do
    topic.reload
    assert_equal false, topic.indexed_changed?
    topic.update(title: topic.title + "1")
    assert_equal true, topic.indexed_changed?
  end

  test ".indexed_changed? with body changed" do
    topic.reload
    assert_equal false, topic.indexed_changed?
    topic.update(body: topic.body + "1")
    assert_equal true, topic.indexed_changed?
  end

  test ".indexed_changed? with other changed" do
    topic.reload
    assert_equal false, topic.indexed_changed?
    topic.node_id = 3
    topic.last_reply_id = 3
    topic.who_deleted = "122"
    topic.last_active_mark = Time.now.to_i
    topic.suggested_at = Time.now
    topic.save
    assert_equal false, topic.indexed_changed?
  end

  test "RateLimit should limtest by minute" do
    Setting.stubs(:topic_create_limit_interval).returns(60)
    user_id = 11
    t = build(:topic, user_id: user_id)
    assert_equal true, t.save
    assert_equal false, t.new_record?
    assert_equal 1, Rails.cache.read("users:#{user_id}:topic-create")
    assert_equal 1, Rails.cache.read("users:#{user_id}:topic-create-by-hour")

    t = build(:topic, user_id: user_id)
    assert_equal false, t.save
    assert_equal 1, t.errors.count
    assert_equal ["Create too frequently, please try again later."], t.errors.messages_for(:base)

    Rails.cache.delete("users:#{user_id}:topic-create")
    Setting.stubs(:topic_create_limit_interval).returns(0)
    t = build(:topic, user_id: user_id)
    t.save!
    assert_nil Rails.cache.read("users:#{user_id}:topic-create")
  end

  test "RateLimit should limtest by hour" do
    user_id = 12

    create(:topic, user_id: user_id)
    count = Rails.cache.read("users:#{user_id}:topic-create-by-hour")
    assert_equal 1, count

    create(:topic, user_id: user_id)
    count = Rails.cache.read("users:#{user_id}:topic-create-by-hour")
    assert_equal 2, count

    Setting.stubs(:topic_create_hour_limit_count).returns(10)
    Rails.cache.write("users:#{user_id}:topic-create-by-hour", 10)
    topic = build(:topic, user_id: user_id)
    assert_equal false, topic.save
    assert_equal ["Creation has been rejected by limit 10 topics created within 1 hour."], topic.errors.messages_for(:base)

    Setting.stubs(:topic_create_hour_limit_count).returns(0)
    topic = build(:topic, user_id: user_id)
    topic.save!
  end

  test "Ban word in topic" do
    Setting.stubs(:ban_words_in_body).returns(["FFF", "AAAA"])
    topic = build(:topic, body: "This is CCC")
    assert_equal true, topic.valid?
    topic = build(:topic, body: "This is FFFF")
    assert_equal false, topic.valid?
    assert_equal ["Create failed, because content has sensitive word \"FFF\"."], topic.errors.messages_for(:body)
    topic = build(:topic, body: "This is AAAA")
    assert_equal false, topic.valid?
    assert_equal ["Create failed, because content has sensitive word \"AAAA\"."], topic.errors.messages_for(:body)
  end

  test "as_indexed_json" do
    topic = build(:topic, title: "hello world", body: "This **is** body New line")
    json = topic.as_indexed_json
    assert_equal "hello world", json["title"]
    assert_equal "This is body New line", json["body"]
  end
end
