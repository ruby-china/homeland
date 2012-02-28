require 'spec_helper'

describe Node do

  describe 'Validates' do
    it 'should fail saving without specifing a section' do
      node = Node.new
      node.name = "Cersei"
      node.summary = "the Queue"
      node.save == false
    end
  end

  describe "CacheVersion update" do
    it "should update on save" do
      old = CacheVersion.section_node_updated_at
      sleep(1)
      node = Factory(:node)
      CacheVersion.section_node_updated_at.should_not == old      
    end

    it "should update on destroy" do
      node = Factory(:node)
      old = CacheVersion.section_node_updated_at
      sleep(1)
      node.destroy
      CacheVersion.section_node_updated_at.should_not == old      
    end
  end

end
