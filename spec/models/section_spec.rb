require 'spec_helper'

describe Section do

  describe "CacheVersion update" do
    it "should update on save" do
      old = CacheVersion.section_node_updated_at
      sleep(1)
      section = Factory(:section)
      CacheVersion.section_node_updated_at.should_not == old      
    end

    it "should update on destroy" do
      section = Factory(:section)
      old = CacheVersion.section_node_updated_at
      sleep(1)
      section.destroy
      CacheVersion.section_node_updated_at.should_not == old      
    end
  end

end
