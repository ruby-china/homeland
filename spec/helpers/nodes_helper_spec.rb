require "spec_helper"

describe NodesHelper do
  it "should render_node_summary" do
    @node = Factory :node
    helper.render_node_summary(@node).should == %{<p class="summary">#{@node.summary}</p>}
  end
end
