require 'rails_helper'
require 'cancan/matchers'

describe Ability, type: :model do
  subject { ability }

  context 'Admin manage all' do
    let(:admin) { create :admin }
    let(:ability) { Ability.new(admin) }

    it { is_expected.to be_able_to(:manage, Topic) }
    it { is_expected.to be_able_to(:manage, Reply) }
    it { is_expected.to be_able_to(:manage, Section) }
    it { is_expected.to be_able_to(:manage, Node) }
    it { is_expected.to be_able_to(:manage, Page) }
    it { is_expected.to be_able_to(:manage, PageVersion) }
    it { is_expected.to be_able_to(:manage, Site) }
    it { is_expected.to be_able_to(:manage, Note) }
    it { is_expected.to be_able_to(:manage, Photo) }
    it { is_expected.to be_able_to(:manage, Comment) }
    it { is_expected.to be_able_to(:manage, Team) }
    it { is_expected.to be_able_to(:manage, TeamUser) }
  end

  context 'Wiki Editor manage wiki' do
    let(:wiki_editor) { create :wiki_editor }
    let(:ability) { Ability.new(wiki_editor) }
    let(:page_locked) { create :page, locked: true }

    it { is_expected.not_to be_able_to(:destroy, Page) }
    it { is_expected.not_to be_able_to(:suggest, Topic) }
    it { is_expected.not_to be_able_to(:unsuggest, Topic) }
    it { is_expected.to be_able_to(:create, Page) }
    it { is_expected.to be_able_to(:update, Page) }
    it { is_expected.not_to be_able_to(:update, page_locked) }
    it { is_expected.to be_able_to(:create, Team) }
  end

  context 'Site editor users' do
    let(:site_editor) { create :user, replies_count: 100 }
    let(:ability) { Ability.new(site_editor) }

    context 'Site' do
      it { is_expected.to be_able_to(:read, Site) }
      it { is_expected.to be_able_to(:create, Site) }
    end
  end

  context 'Normal users' do
    let(:user) { create :avatar_user }
    let(:topic) { create :topic, user: user }
    let(:topic1) { create :topic }
    let(:locked_topic) { create :topic, user: user, lock_node: true }
    let(:reply) { create :reply, user: user }
    let(:note) { create :note, user: user }
    let(:comment) { create :comment, user: user }
    let(:team_owner) { create :team_owner, user: user }
    let(:team_member) { create :team_member, user: user }
    let(:note_publish) { create :note, publish: true }

    let(:ability) { Ability.new(user) }

    context 'Topic' do
      it { is_expected.to be_able_to(:read, Topic) }
      it { is_expected.to be_able_to(:create, Topic) }
      it { is_expected.to be_able_to(:update, topic) }
      it { is_expected.to be_able_to(:destroy, topic) }
      it { is_expected.not_to be_able_to(:suggest, Topic) }
      it { is_expected.not_to be_able_to(:unsuggest, Topic) }
      it { is_expected.not_to be_able_to(:ban, Topic) }
      it { is_expected.not_to be_able_to(:open, topic1) }
      it { is_expected.not_to be_able_to(:close, topic1) }
      it { is_expected.not_to be_able_to(:ban, topic) }
      it { is_expected.to be_able_to(:open, topic) }
      it { is_expected.to be_able_to(:close, topic) }
      it { is_expected.to be_able_to(:change_node, topic) }
      it { is_expected.not_to be_able_to(:change_node, locked_topic) }
      it { is_expected.to be_able_to(:change_node, topic) }
    end

    context 'Reply' do
      context 'normal' do
        it { is_expected.to be_able_to(:read, Reply) }
        it { is_expected.to be_able_to(:create, Reply) }
        it { is_expected.to be_able_to(:update, reply) }
        it { is_expected.to be_able_to(:destroy, reply) }
      end

      context 'Reply that Topic closed' do
        let(:t) { create(:topic, closed_at: Time.now) }
        let(:r) { Reply.new(topic: t) }

        it { is_expected.not_to be_able_to(:create, r) }
        it { is_expected.not_to be_able_to(:update, r) }
        it { is_expected.not_to be_able_to(:destroy, r) }
      end
    end

    context 'Section' do
      it { is_expected.to be_able_to(:read, Section) }
    end

    context 'Node' do
      it { is_expected.to be_able_to(:read, Node) }
    end

    context 'Note' do
      it { is_expected.to be_able_to(:read, Note.new(publish: true)) }
      it { is_expected.not_to be_able_to(:read, Note.new(publish: false)) }
    end

    context 'Page (WIKI)' do
      it { is_expected.to be_able_to(:read, Page) }
    end

    context 'Site' do
      it { is_expected.to be_able_to(:read, Site) }
      it { is_expected.not_to be_able_to(:create, Site) }
    end

    context 'Note' do
      it { is_expected.to be_able_to(:create, Note) }
      it { is_expected.to be_able_to(:read, note) }
      it { is_expected.to be_able_to(:update, note) }
      it { is_expected.to be_able_to(:destroy, note) }
      it { is_expected.to be_able_to(:read, note_publish) }
    end

    context 'Photo' do
      it { is_expected.to be_able_to(:create, Photo) }
      it { is_expected.to be_able_to(:read, Photo) }
    end

    context 'Comment' do
      it { is_expected.to be_able_to(:create, Comment) }
      it { is_expected.to be_able_to(:read, Comment) }
      it { is_expected.to be_able_to(:update, comment) }
      it { is_expected.to be_able_to(:destroy, comment) }
    end

    context 'Team' do
      it { is_expected.not_to be_able_to(:create, Team) }
      it { is_expected.to be_able_to(:read, Team) }
      it { is_expected.to be_able_to(:update, team_owner.team) }
      it { is_expected.not_to be_able_to(:update, team_member.team) }
      it { is_expected.to be_able_to(:destroy, team_owner.team) }
      it { is_expected.not_to be_able_to(:destroy, team_member.team) }
    end

    context 'TeamUser' do
      it { is_expected.to be_able_to(:accept, team_member) }
      it { is_expected.to be_able_to(:reject, team_member) }
    end
  end

  context 'Normal user but no avatar' do
    let(:user) { create :user }
    let(:ability) { Ability.new(user) }

    it { is_expected.to be_able_to(:create, Topic) }
  end

  context 'Newbie users' do
    let(:newbie) { create :newbie }
    let(:ability) { Ability.new(newbie) }

    context 'Topic' do
      it { is_expected.not_to be_able_to(:create, Topic) }
      it { is_expected.not_to be_able_to(:suggest, Topic) }
      it { is_expected.not_to be_able_to(:unsuggest, Topic) }
    end

    context 'Reply' do
      it { is_expected.to be_able_to(:create, Reply) }
    end
  end

  context 'Blocked users' do
    let(:blocked_user) { create :blocked_user }
    let(:ability) { Ability.new(blocked_user) }

    context 'Topic' do
      it { is_expected.not_to be_able_to(:create, Topic) }
    end
    context 'Reply' do
      it { is_expected.not_to be_able_to(:create, Reply) }
    end
    context 'Comment' do
      it { is_expected.not_to be_able_to(:create, Comment) }
    end
    context 'Photo' do
      it { is_expected.not_to be_able_to(:create, Photo) }
    end
    context 'Page' do
      it { is_expected.not_to be_able_to(:create, Page) }
    end
  end

  context 'Deleted users' do
    let(:deleted_user) { create :deleted_user }
    let(:ability) { Ability.new(deleted_user) }
    context 'Topic' do
      it { is_expected.not_to be_able_to(:create, Topic) }
    end
    context 'Reply' do
      it { is_expected.not_to be_able_to(:create, Reply) }
    end
    context 'Comment' do
      it { is_expected.not_to be_able_to(:create, Comment) }
    end
    context 'Photo' do
      it { is_expected.not_to be_able_to(:create, Photo) }
    end
    context 'Page' do
      it { is_expected.not_to be_able_to(:create, Page) }
    end
  end
end
