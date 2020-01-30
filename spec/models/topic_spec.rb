# frozen_string_literal: true

require "rails_helper"

describe Topic, type: :model do
  let(:topic) { create(:topic) }
  let(:user) { create(:user) }

  it "should no save invalid node_id" do
    refute_equal true, build(:topic, node_id: nil).valid?
  end

  it "should set last_active_mark on created" do
    # because the Topic index is sort by replied_at,
    # so the new Topic need to set a Time, that it will display in index page
    refute_nil create(:topic).last_active_mark
  end

  it "should not update last_active_mark on save" do
    last_active_mark_was = topic.last_active_mark
    topic.save
    assert_equal last_active_mark_was, topic.last_active_mark
  end

  it "should get node name" do
    node = create :node
    assert_equal node.name, create(:topic, node: node).node_name
  end

  it "should update after reply" do
    reply = create :reply, topic: topic, user: user
    refute_nil topic.last_active_mark
    assert_equal reply.created_at.to_i, topic.replied_at.to_i
    assert_equal reply.id, topic.last_reply_id
    assert_equal reply.user_id, topic.last_reply_user_id
    assert_equal reply.user.login, topic.last_reply_user_login
  end

  it "should update after reply without last_active_mark when the topic is created at month ago" do
    allow(topic).to receive(:created_at).and_return(1.month.ago)
    allow(topic).to receive(:last_active_mark).and_return(1)
    reply = create :reply, topic: topic, user: user
    refute_equal reply.created_at.to_i, topic.last_active_mark
    assert_equal reply.user_id, topic.last_reply_user_id
    assert_equal reply.user.login, topic.last_reply_user_login
  end

  it "should not update last_active_mark when update reply" do
    reply = create :reply, topic: topic, user: user
    old_last_active_mark = topic.last_active_mark
    reply.body = "foobar"
    reply.save
    assert_equal old_last_active_mark, topic.last_active_mark
  end

  it "should get page and floor by reply" do
    replies = []
    5.times do
      replies << create(:reply, topic: topic, user: user)
    end
    assert_equal 3, topic.floor_of_reply(replies[2])
    assert_equal 4, topic.floor_of_reply(replies[3])
  end

  it "should log deleted user name when use destroy_by" do
    t = create(:topic)
    t.destroy_by(user)
    assert_equal user.login, t.who_deleted
    refute_equal nil, t.deleted_at
    t1 = create(:topic)
    assert_equal false, t1.destroy_by(nil)
  end

  describe "#auto_space_with_en_zh" do
    it "should auto fix on save" do
      topic.title = "Gitlab怎么集成GitlabCI"
      topic.save
      topic.reload
      assert_equal "Gitlab 怎么集成 GitlabCI", topic.title
    end
  end

  describe "#excellent" do
    it "should suggest a topic as excellent" do
      topic.excellent!
      topic.save
      expect(Topic.excellent).to include(topic)
    end
  end

  describe ".update_last_reply" do
    it "should work" do
      t = create(:topic)
      old_updated_at = t.updated_at
      r = create(:reply, topic: t)
      assert_equal true, t.update_last_reply(r)
      assert_equal r.created_at, t.replied_at
      assert_equal r.id, t.last_reply_id
      assert_equal r.user_id, t.last_reply_user_id
      assert_equal r.user.login, t.last_reply_user_login
      refute_nil t.last_active_mark
      refute_equal old_updated_at, t.updated_at
    end

    it "should update with nil when have :force" do
      t = create(:topic)
      t.update_last_reply(nil, force: true)
      assert_nil t.replied_at
      assert_nil t.last_reply_id
      assert_nil t.last_reply_user_id
      assert_nil t.last_reply_user_login
      refute_nil t.last_active_mark
    end
  end

  describe ".update_deleted_last_reply" do
    let(:t) { create(:topic) }
    context "when have last Reply and param it that Reply" do
      it "last reply should going to previous Reply" do
        r0 = create(:reply, topic: t)
        create(:reply, action: "foo")
        r1 = create(:reply, topic: t)
        assert_equal r1.id, t.last_reply_id
        expect(t).to receive(:update_last_reply).with(r0, force: true)
        t.update_deleted_last_reply(r1)
      end

      it "last reply will be nil" do
        r = create(:reply, topic: t)
        assert_equal true, t.update_deleted_last_reply(r)
        t.reload
        assert_nil t.last_reply_id
        assert_nil t.last_reply_user_login
        assert_nil t.last_reply_user_id
      end
    end

    context "when param is nil" do
      it "should work" do
        assert_equal false, t.update_deleted_last_reply(nil)
      end
    end

    context "when last reply is not equal param" do
      it "should do nothing" do
        r0 = create(:reply, topic: t)
        r1 = create(:reply, topic: t)
        assert_equal false, t.update_deleted_last_reply(r0)
        assert_equal r1.id, t.last_reply_id
      end
    end
  end

  describe "#notify_topic_created" do
    let(:followers) { create_list(:user, 3) }
    let(:topic) { create(:topic, user: user) }

    it "should work" do
      followers.each do |f|
        f.follow_user(user)
      end

      # touch topic to create
      expect(topic).to be_a(Topic)

      followers.each do |f|
        expect(f.notifications.unread.where(notify_type: "topic").count).to eq 1
      end
    end
  end

  describe "#notify_topic_node_changed" do
    let(:topic) { create(:topic, user: user) }
    let(:new_node) { create(:node) }

    describe "Call method" do
      it "should work" do
        Topic.notify_topic_node_changed(topic.id, new_node.id)
        last_notification = user.notifications.unread.where(notify_type: "node_changed").first
        assert_equal "Topic", last_notification.target_type
        assert_equal topic.id, last_notification.target_id
        assert_equal "Node", last_notification.second_target_type
        assert_equal new_node.id, last_notification.second_target_id
      end
    end

    describe "on save callback" do
      it "with admin_editing no node_id changed" do
        topic.admin_editing = true
        expect(Topic).not_to receive(:notify_topic_node_changed)
        topic.save
      end

      it "with admin_editing and node_id_changed" do
        topic.admin_editing = true
        topic.node_id = new_node.id
        expect(Topic).to receive(:notify_topic_node_changed).once
        topic.save
      end

      it "without admin_editing" do
        topic.admin_editing = false
        topic.node_id = new_node.id
        topic.save
        expect(Topic).not_to receive(:notify_topic_node_changed)
      end
    end
  end

  describe ".ban!" do
    let!(:t) { create(:topic, user: user) }

    it "should ban! and lock topic" do
      t.ban!
      t.reload
      assert_equal true, t.ban?
    end

    it "should ban! with reason" do
      allow(User).to receive(:current).and_return(user)
      t.ban!(reason: "Block this topic")
      t.reload
      assert_equal true, t.ban?
      r = t.replies.last
      assert_equal "ban", r.action
      assert_equal "Block this topic", r.body
    end
  end

  describe ".reply_ids" do
    let(:t) { create(:topic) }
    let!(:replies) { create_list(:reply, 10, topic: t) }

    it "should work" do
      assert_equal replies.collect(&:id), t.reply_ids
    end
  end

  describe ".close! / .open! / closed?" do
    let!(:t) { create(:topic, user: user) }

    it "should work" do
      t.close!
      assert_equal true, t.closed?
      t.open!
      assert_nil t.closed_at
      assert_equal false, t.closed?
      t.close!
    end
  end

  describe ".excellent! / .unexcellent!" do
    let!(:t) { create(:topic, user: user) }

    it "should work" do
      allow(User).to receive(:current).and_return(user)
      expect do
        t.excellent!
      end.to change(Reply.where(action: "excellent", user: user), :count).by(1)
      assert_equal true, t.excellent?
      expect do
        t.unexcellent!
      end.to change(Reply.where(action: "unexcellent", user: user), :count).by(1)
      assert_equal false, t.excellent?
    end
  end

  describe "Search methods" do
    let(:t) { create :topic }

    before(:each) do
      t.reload
    end

    describe ".indexed_changed?" do
      it "title changed work" do
        assert_equal false, t.indexed_changed?
        t.update(title: t.title + "1")
        assert_equal true, t.indexed_changed?
      end

      it "body changed work" do
        assert_equal false, t.indexed_changed?
        t.update(body: t.body + "1")
        assert_equal true, t.indexed_changed?
      end

      it "other changed work" do
        assert_equal false, t.indexed_changed?
        t.node_id = 3
        t.last_reply_id = 3
        t.who_deleted = "122"
        t.last_active_mark = Time.now.to_i
        t.suggested_at = Time.now
        t.save
        assert_equal false, t.indexed_changed?
      end
    end
  end

  describe "RateLimit" do
    it "should limit by minute" do
      allow(Setting).to receive(:topic_create_limit_interval).and_return(60)
      user_id = 11
      t = build(:topic, user_id: user_id)
      assert_equal true, t.save
      assert_equal false, t.new_record?
      assert_equal 1, Rails.cache.read("users:#{user_id}:topic-create")
      assert_equal 1, Rails.cache.read("users:#{user_id}:topic-create-by-hour")

      t = build(:topic, user_id: user_id)
      assert_equal false, t.save
      assert_equal 1, t.errors.count
      assert_equal ["创建太频繁，请稍后再试"], t.errors&.messages.dig(:base)

      Rails.cache.delete("users:#{user_id}:topic-create")
      allow(Setting).to receive(:topic_create_limit_interval).and_return(0)
      t = build(:topic, user_id: user_id)
      t.save!
      assert_nil Rails.cache.read("users:#{user_id}:topic-create")
    end

    it "should limit by hour" do
      user_id = 12

      create(:topic, user_id: user_id)
      count = Rails.cache.read("users:#{user_id}:topic-create-by-hour")
      assert_equal 1, count

      create(:topic, user_id: user_id)
      count = Rails.cache.read("users:#{user_id}:topic-create-by-hour")
      assert_equal 2, count

      allow(Setting).to receive(:topic_create_hour_limit_count).and_return(10)
      Rails.cache.write("users:#{user_id}:topic-create-by-hour", 10)
      t = build(:topic, user_id: user_id)
      assert_equal false, t.save
      assert_equal ["1 小时内创建话题量不允许超过 10 篇，无法再次发布"], t.errors&.messages.dig(:base)

      allow(Setting).to receive(:topic_create_hour_limit_count).and_return(0)
      t = build(:topic, user_id: user_id)
      t.save!
    end
  end

  describe "Ban word in topic" do
    it "should work" do
      allow(Setting).to receive(:ban_words_in_body).and_return(["FFF", "AAAA"])
      t = build(:topic, body: "This is CCC")
      assert_equal true, t.valid?
      t = build(:topic, body: "This is FFFF")
      assert_equal false, t.valid?
      assert_equal ["敏感词 “FFF” 禁止发布！"],  t.errors&.messages.dig(:body)
      t = build(:topic, body: "This is AAAA")
      assert_equal false, t.valid?
      assert_equal ["敏感词 “AAAA” 禁止发布！"],  t.errors&.messages.dig(:body)
    end
  end
end
