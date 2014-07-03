require 'rails_helper'

describe Section, :type => :model do

  describe "CacheVersion update" do
    it "should update on save" do
      old = CacheVersion.section_node_updated_at
      sleep(1)
      section = Factory(:section)
      expect(CacheVersion.section_node_updated_at).not_to eq(old)      
    end

    it "should update on destroy" do
      section = Factory(:section)
      old = CacheVersion.section_node_updated_at
      sleep(1)
      section.destroy
      expect(CacheVersion.section_node_updated_at).not_to eq(old)      
    end
  end

end
