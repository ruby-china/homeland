require "spec_helper"

describe TopicsCell do
  before(:each) do
    @section = Factory :section
    @node = Factory :node, :section => @section
    @topic = Factory :topic, :node => @node
    @topic2 = Factory :topic, :node => @node
    @topic3 = Factory :topic, :node => @node
  end

  describe "index_sections" do
    it "should render sections" do
      render_cell(:topics, :index_sections).should have_css('div#sections li', :count => 1)
    end
  end

  describe "sidebar_statistics" do
    it "should render sidebar stats" do
      render_cell(:topics, :sidebar_statistics).should have_css("div.totals", :count => 1)
    end
  end

  describe "sidebar_hot_nodes" do
    it "should render sidebar hot nodes" do
      render_cell(:topics, :sidebar_hot_nodes).should have_css("div.hot_nodes li", :count => 1)
    end
  end

  describe "sidebar_suggest_topics" do
    it "should render sidebar_suggest_topics" do
      render_cell(:topics, :sidebar_suggest_topics).should have_css("div.suggest_topics", :count => 1)
    end
  end

  describe "sidebar_for_new_topic_node" do
    it "should render when node presents" do
      render_cell(:topics, :sidebar_for_new_topic_node, :node => @node).should have_css("div.content", :count => 1)
    end

    it "should not render when node not presents" do
      render_cell(:topics, :sidebar_for_new_topic_node).should_not have_css("div.content")
    end
  end

  describe "sidebar_for_more_like_this" do
    it "should render sidebar_for_more_like_this" do
      @topic.stub_chain(:more_like_this, :results).and_return([@topic2, @topic3])
      render_cell(:topics, :sidebar_for_more_like_this, :topic => @topic).should have_css("div li", :count => 2)
    end
  end

  describe "reply_help_block" do
    it "should render reply_help_block" do
      render_cell(:topics, :reply_help_block).should have_css('div#markdown_help_tip_modal')
    end
  end

  describe "index_locations" do
    it "should render hot locations" do
      User.stub(:hot_locations).and_return(["Shanghai", "Osaka", "Tokyo"])
      render_cell(:topics, :index_locations).should have_css('div#hot_locations li.name', :count => 3)
    end
  end
end
