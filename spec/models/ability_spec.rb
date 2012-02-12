require 'spec_helper'
require "cancan/matchers"

describe Ability do
  subject { ability }

  context "Admin manage all" do
    let(:admin) { Factory :admin }
    let(:ability){ Ability.new(admin) }
    it { should be_able_to(:manage, Topic) }
    it { should be_able_to(:manage, Reply) }
    it { should be_able_to(:manage, Section) }
    it { should be_able_to(:manage, Node) }
    it { should be_able_to(:manage, Page) }
    it { should be_able_to(:manage, PageVersion) }
    it { should be_able_to(:manage, Site) }
    it { should be_able_to(:manage, Note) }
    it { should be_able_to(:manage, Photo) }
    it { should be_able_to(:manage, Comment) }
  end

  context "Wiki Editor manage wiki" do
    let(:wiki_editor) { Factory :wiki_editor }
    let(:ability){ Ability.new(wiki_editor) }
    let(:page_locked) { Factory :page, :locked => true }
    it { should_not be_able_to(:destroy, Page) }
    it { should be_able_to(:create, Page) }
    it { should be_able_to(:update, Page) }
    it { should_not be_able_to(:update, page_locked)}
  end

  context "Normal users" do
    let(:user) { Factory :user }
    let(:topic) { Factory :topic, :user => user }
    let(:reply) { Factory :reply, :user => user }
    let(:note) { Factory :note, :user => user }
    let(:comment) { Factory :comment, :user => user }
    let(:note_publish) { Factory :note, :publish => true }

    let(:ability){ Ability.new(user) }

    context "Topic" do
      it { should be_able_to(:read, Topic) }
      it { should be_able_to(:create, Topic) }
      it { should be_able_to(:update, topic) }
      it { should be_able_to(:destroy, topic) }
    end

    context "Reply" do
      it { should be_able_to(:read, Reply) }
      it { should be_able_to(:create, Reply) }
      it { should be_able_to(:update, reply) }
      it { should be_able_to(:destroy, reply) }
    end

    context "Section" do
      it { should be_able_to(:read, Section) }
    end

    context "Node" do
      it { should be_able_to(:read, Node) }
    end

    context "Page (WIKI)" do
      it { should be_able_to(:read, Page) }
    end

    context "Site" do
      it { should be_able_to(:read, Site) }
      it { should be_able_to(:create, Site) }
    end

    context "Note" do
      it { should be_able_to(:create, Note) }
      it { should be_able_to(:read, note) }
      it { should be_able_to(:update, note) }
      it { should be_able_to(:destroy, note) }
      it { should be_able_to(:read, note_publish) }
    end

    context "Photo" do
      it { should be_able_to(:create, Photo) }
      it { should be_able_to(:read, Photo) }
    end

    context "Comment" do
      it { should be_able_to(:create, Comment) }
      it { should be_able_to(:read, Comment) }
      it { should be_able_to(:update, comment) }
      it { should be_able_to(:destroy, comment) }
    end
  end
end
