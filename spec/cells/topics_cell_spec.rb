require "rails_helper"

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
      expect(render_cell(:topics, :index_sections)).to have_css('div#sections li', :count => 1)
    end
  end

  describe "sidebar_statistics" do
    it "should render sidebar stats" do
      expect(render_cell(:topics, :sidebar_statistics)).to have_css("div.totals", :count => 1)
    end
  end
  
  describe "reply_help_block" do
    it "should render reply_help_block" do
      expect(render_cell(:topics, :reply_help_block)).to have_css('div#markdown_help_tip_modal')
    end
  end

  describe "index_locations" do
    it "should render hot locations" do
      l1 = Factory(:location)
      l2 = Factory(:location)
      l3 = Factory(:location)
      count = Location.count
      count = 12 if count > 12
      expect(render_cell(:topics, :index_locations)).to have_css('div#hot_locations li.name', :count => count)
    end
  end

  describe "sidebar_for_node_recent_topics" do
    let(:node) { Factory(:node) }
    let(:topic0) { Factory(:topic, :node => node) }

    it "should not render if node only has one topic" do
      expect(render_cell(:topics, :sidebar_for_node_recent_topics, :topic => topic0)).not_to have_css("div.box ul li")
    end

    it "should render" do
      topic1 = Factory(:topic, :node => node)
      expect(render_cell(:topics, :sidebar_for_node_recent_topics, :topic => topic0)).to have_css("div.box ul li", :count => 1)
    end

    it "shoudl render more when Topic have more replies" do
      reply0 = Factory(:reply, :topic => topic0)
      reply1 = Factory(:reply, :topic => topic0)
      reply2 = Factory(:reply, :topic => topic0)
      topic1 = Factory(:topic, :node => node)
      topic2 = Factory(:topic, :node => node)
      expect(render_cell(:topics, :sidebar_for_node_recent_topics, :topic => topic0)).to have_css("div.box ul li", :count => 2)
    end
  end

  describe "tips" do
    it "should render tips" do
      expect(render_cell(:topics, :tips)).to have_css("div.box", :count => 1)
    end
  end
end
