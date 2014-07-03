require "rails_helper"

describe NodesHelper, :type => :helper do
  it "should render_node_summary" do
    @node = Factory :node
    expect(helper.render_node_summary(@node)).to eq(%{<p class="summary">#{@node.summary}</p>})
  end
end
