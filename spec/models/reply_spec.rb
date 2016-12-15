require 'rails_helper'

describe Reply, type: :model do
  let(:user) { create(:user) }

  describe 'notifications' do
    it 'should delete mention notification after destroy' do
      expect do
        create(:reply, body: "@#{user.login}").destroy
      end.not_to change(user.notifications.unread, :count)
    end

    it 'should send topic reply notification to topic author' do
      topic = create :topic, user: user
      expect do
        create :reply, topic: topic
      end.to change(Notification, :count).by(1)

      expect do
        create(:reply, topic: topic).destroy
      end.not_to change(user.notifications.unread, :count)

      expect do
        create :reply, topic: topic, user: user
      end.not_to change(user.notifications.unread, :count)

      # Don't duplicate notifiation with mention
      expect do
        create :reply, topic: topic, mentioned_user_ids: [user.id]
      end.not_to change(user.notifications.unread.where(notify_type: 'topic_reply'), :count)
    end

    describe 'should send topic reply notification to followers' do
      let(:u1) { create(:user) }
      let(:u2) { create(:user) }
      let!(:t) { create(:topic, follower_ids: [u1.id, u2.id]) }

      # 正常状况
      it 'should work' do
        expect do
          create :reply, topic: t, user: user
        end.to change(u1.notifications, :count).by(1)
      end

      # TODO: 需要更多的测试，测试 @ 并且有关注的时候不会重复通知，回复时候不会通知自己
    end

    describe 'should boardcast replies to client' do
      it 'should work' do
        expect(Reply).to receive(:broadcast_to_client).once
        create :reply
      end
    end

    describe 'Touch Topic in callback' do
      let(:topic) { create :topic, updated_at: 1.days.ago }
      let(:reply) { create :reply, topic: topic }

      it 'should update Topic updated_at on Reply updated' do
        old_updated_at = topic.updated_at
        reply.body = 'foobar'
        reply.save
        expect(topic.updated_at).not_to eq(old_updated_at)
      end

      it 'should update Topic updated_at on Reply deleted' do
        old_updated_at = topic.updated_at
        reply.body = 'foobar'
        reply.destroy
        expect(topic.updated_at).not_to eq(old_updated_at)
      end

      context 'system reply' do
        let(:target) { create(:topic) }
        it 'should not change topic last_replied_at when reply created' do
          system_reply = build(:reply, action: 'mention', topic: topic, target: target)
          old_last_active_mark = topic.last_active_mark
          old_replied_at = topic.replied_at
          expect(topic).not_to receive(:update_last_reply)
          system_reply.save
          expect(system_reply.new_record?).to eq false
          topic.reload
          expect(topic.last_active_mark).to eq old_last_active_mark
          expect(topic.replied_at).to eq old_replied_at
        end
      end
    end

    describe 'Send reply notification' do
      let(:followers) { create_list(:user, 3) }
      let(:replyer) { create :user }

      it 'should notify_reply_created work' do
        followers.each do |f|
          f.follow_user(replyer)
        end

        topic = create :topic, user: user
        reply = create :reply, topic: topic, user: replyer
        create :reply, action: 'nopoint', topic: topic, user: replyer

        followers.each do |f|
          expect(f.notifications.unread.where(notify_type: 'topic_reply').count).to eq 1
        end

        expect do
          Reply.notify_reply_created(reply.id)
        end.to change(user.notifications.unread.where(notify_type: 'topic_reply'), :count).by(1)
      end
    end
  end

  describe 'ban words for Reply body' do
    let(:topic) { create(:topic) }
    it 'should work' do
      allow(Setting).to receive(:ban_words_on_reply).and_return("mark\n顶")
      expect(topic.replies.create(body: '顶', user: user).errors[:body].size).to eq(1)
      expect(topic.replies.create(body: 'mark', user: user).errors[:body].size).to eq(1)
      expect(topic.replies.create(body: ' mark ', user: user).errors[:body].size).to eq(1)
      expect(topic.replies.create(body: 'MARK', user: user).errors[:body].size).to eq(1)
      expect(topic.replies.create(body: 'mark1', user: user).errors[:body].size).to eq(0)
      allow(Setting).to receive(:ban_words_on_reply).and_return("mark\r\n顶")
      expect(topic.replies.create(body: 'mark', user: user).errors[:body].size).to eq(1)
    end

    it 'should work when site_config value is nil' do
      allow(Setting).to receive(:ban_words_on_reply).and_return(nil)
      t = topic.replies.create(body: 'mark', user: user)
      expect(t.errors[:body].size).to eq(0)
    end
  end

  describe 'after_destroy' do
    it 'should call topic.update_deleted_last_reply' do
      r = create(:reply)
      expect(r.topic).to receive(:update_deleted_last_reply).with(r).once
      r.destroy
    end
  end

  describe 'Vote by content' do
    let(:reply) { build :reply }

    describe '.upvote?' do
      let(:chars) { %w(+1 :+1: :thumbsup: :plus1: 👍 👍🏻 👍🏼 👍🏽 👍🏾 👍🏿) }
      it 'should work' do
        chars.each do |key|
          reply.body = key
          expect(reply.upvote?).to eq(true)
        end

        reply.body = 'Ok +1'
        expect(reply.upvote?).to eq(false)
      end
    end

    describe '.check_vote_chars_for_like_topic' do
      let(:user) { create :user }
      let(:topic) { create :topic }
      let(:reply) { build :reply, user: user, topic: topic }

      context 'UpVote' do
        it 'should work' do
          expect(user).to receive(:like).with(topic).once
          allow(reply).to receive(:upvote?).and_return(true)
          reply.check_vote_chars_for_like_topic
        end
      end

      context 'None' do
        it 'should work' do
          expect(user).to receive(:like).with(topic).at_most(0).times
          allow(reply).to receive(:upvote?).and_return(false)
          reply.check_vote_chars_for_like_topic
        end
      end

      context 'callback on created' do
        it 'should work' do
          expect(reply).to receive(:check_vote_chars_for_like_topic).once
          reply.save
        end
      end
    end
  end

  describe '#broadcast_to_client' do
    let(:reply) { create(:reply) }

    it 'should work' do
      args = ["topics/#{reply.topic_id}/replies", { id: reply.id, user_id: reply.user_id, action: :create }]
      expect(ActionCable.server).to receive(:broadcast).with(*args).once
      Reply.broadcast_to_client(reply)
    end
  end

  describe '#create_system_event' do
    it 'should create system event with empty body' do
      allow(User).to receive(:current).and_return(user)
      reply = Reply.create_system_event(topic_id: 1, action: 'bbb')
      expect(reply.system_event?).to eq true
      expect(reply.new_record?).to eq false
    end
  end

  describe '.default_notification' do
    let(:reply) { create(:reply, topic: create(:topic)) }

    it 'should work' do
      val = {
        notify_type: 'topic_reply',
        target_type: 'Reply', target_id: reply.id,
        second_target_type: 'Topic', second_target_id: reply.topic_id,
        actor_id: reply.user_id
      }
      expect(reply.default_notification).to eq val
    end
  end

  describe '.notification_receiver_ids' do
    let(:mentioned_user_ids) { [1, 2, 3] }
    let(:user) { create(:user, follower_ids: [2, 3, 5, 7, 9]) }
    let(:topic) { create(:topic, user_id: 10, follower_ids: [1, 3, 7, 11, 12, 14, user.id]) }
    let(:reply) { create(:reply, user: user, topic: topic, mentioned_user_ids: mentioned_user_ids) }

    it 'should be a Array' do
      expect(reply.notification_receiver_ids).to be_a(Array)
    end

    it 'should not include mentioned_user_ids' do
      expect(reply.notification_receiver_ids).not_to include(*reply.mentioned_user_ids)
    end

    it 'should not include topic follower and topic author' do
      expect(reply.notification_receiver_ids).to include(10)
      expect(reply.notification_receiver_ids).to include(*[7, 11, 12, 14])
    end

    it 'should not include reply user_id' do
      expect(reply.notification_receiver_ids).not_to include(user.id)
    end

    it 'should include replyer followers' do
      expect(reply.notification_receiver_ids).to include(*[5, 7, 9])
    end

    it 'should removed duplicate' do
      expect(reply.notification_receiver_ids).to eq reply.notification_receiver_ids.uniq
    end
  end
end
