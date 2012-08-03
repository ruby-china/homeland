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

  describe "reply_help_block" do
    it "should render reply_help_block" do
      render_cell(:topics, :reply_help_block).should have_css('div#markdown_help_tip_modal')
    end
  end

  describe "index_locations" do
    it "should render hot locations" do
      l1 = Factory(:location)
      l2 = Factory(:location)
      l3 = Factory(:location)
      count = Location.count
      count = 12 if count > 12
      render_cell(:topics, :index_locations).should have_css('div#hot_locations li.name', :count => count)
    end
  end

  describe "high topics" do
    before(:each) do
      t1 = Factory(:topic)
      t2 = Factory(:topic)
      t3 = Factory(:topic)
    end

    it "should render high_likes_topics" do
      count = Topic.by_week.count
      count = 10 if count > 10
      render_cell(:topics, :high_likes_topics).should have_css('div.high_likes_topics li', :count => count)
    end

    it "should render high_replies_topics" do
      count = Topic.by_week.count
      count = 10 if count > 10
      render_cell(:topics, :high_replies_topics).should have_css('div.high_replies_topics li', :count => count)
    end
  end

  describe "sidebar_for_node_recent_topics" do
    let(:node) { Factory(:node) }
    let(:topic0) { Factory(:topic, :node => node) }
    it "should render" do
      render_cell(:topics, :sidebar_for_node_recent_topics, :topic => topic0).should have_css("div.box ul li", :count => 1)
    end

    it "shoudl render more when Topic have more replies" do
      reply0 = Factory(:reply, :topic => topic0)
      reply1 = Factory(:reply, :topic => topic0)
      reply2 = Factory(:reply, :topic => topic0)
      topic1 = Factory(:topic, :node => node)
      render_cell(:topics, :sidebar_for_node_recent_topics, :topic => topic0).should have_css("div.box ul li", :count => 2)
    end
  end

  describe "sidebar_for_new_topic_button_group" do
    let(:node0) { Factory(:node) }
    let(:node1) { Factory(:node) }
    it "should render" do
      SiteConfig.stub!(:new_topic_dropdown_node_ids).and_return([node0.id,node1.id].join(","))
      render_cell(:topics, :sidebar_for_new_topic_button_group).should have_css('ul.dropdown-menu li', :count => 2)
    end

    it "should work on site_config value is nil" do
      SiteConfig.stub!(:new_topic_dropdown_node_ids).and_return(nil)
      render_cell(:topics, :sidebar_for_new_topic_button_group).should have_css('.btn-group')
    end
  end

  describe "tips" do
    it "should render tips" do
      render_cell(:topics, :tips).should have_css("div.box", :count => 1)
    end
  end
end
