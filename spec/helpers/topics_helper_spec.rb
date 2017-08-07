require 'rails_helper'

describe TopicsHelper, type: :helper do
  describe 'topic_favorite_tag' do
    let(:user) { create :user }
    let(:topic) { create :topic }

    it 'should run with nil param' do
      allow(helper).to receive(:current_user).and_return(nil)
      expect(helper.topic_favorite_tag(nil)).to eq('')
    end

    it 'should result when logined user did not favorite topic' do
      allow(user).to receive(:favorite_topic?).and_return(false)
      allow(helper).to receive(:current_user).and_return(user)
      res = helper.topic_favorite_tag(topic)
      expect(res).to eq("<a title=\"收藏\" class=\"bookmark \" data-id=\"1\" href=\"#\"><i class=\"fa fa-bookmark\"></i> 收藏</a>")
    end

    it 'should result when logined user favorited topic' do
      allow(user).to receive(:favorite_topic?).and_return(true)
      allow(helper).to receive(:current_user).and_return(user)
      expect(helper.topic_favorite_tag(topic)).to eq("<a title=\"取消收藏\" class=\"bookmark active\" data-id=\"1\" href=\"#\"><i class=\"fa fa-bookmark\"></i> 收藏</a>")
    end

    it 'should result blank when unlogin user' do
      allow(helper).to receive(:current_user).and_return(nil)
      expect(helper.topic_favorite_tag(topic)).to eq('')
    end
  end

  describe 'topic_title_tag' do
    let(:topic) { create :topic, title: 'test title' }
    let(:user) { create :user }

    it 'should return topic_was_deleted without a topic' do
      expect(helper.topic_title_tag(nil)).to eq(t('topics.topic_was_deleted'))
    end

    it 'should return title with a topic' do
      expect(helper.topic_title_tag(topic)).to eq("<a title=\"#{topic.title}\" href=\"/topics/#{topic.id}\">#{topic.title}</a>")
    end
  end

  describe 'topic_follow_tag' do
    let(:topic) { create :topic }
    let(:user) { create :user }

    it 'should return empty when current_user is nil' do
      allow(helper).to receive(:current_user).and_return(nil)
      expect(helper.topic_follow_tag(topic)).to eq('')
    end

    it 'should return empty when is owner' do
      allow(helper).to receive(:current_user).and_return(topic.user)
      expect(helper.topic_follow_tag(topic)).to eq('')
    end

    it 'should return empty when topic is nil' do
      allow(helper).to receive(:current_user).and_return(user)
      expect(helper.topic_follow_tag(nil)).to eq('')
    end

    context 'was unfollow' do
      it 'should work' do
        allow(helper).to receive(:current_user).and_return(user)
        expect(helper.topic_follow_tag(topic)).to eq "<a data-id=\"#{topic.id}\" class=\"follow\" href=\"#\"><i class=\"fa fa-eye\"></i> 关注</a>"
      end
    end

    context 'was active' do
      it 'should work' do
        allow(helper).to receive(:current_user).and_return(user)
        allow(user).to receive(:follow_topic?).and_return(true)
        expect(helper.topic_follow_tag(topic)).to eq "<a data-id=\"#{topic.id}\" class=\"follow active\" href=\"#\"><i class=\"fa fa-eye\"></i> 关注</a>"
      end
    end
  end
end
