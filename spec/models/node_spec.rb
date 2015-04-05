require 'rails_helper'

describe Node, :type => :model do

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
      expect(CacheVersion.section_node_updated_at).not_to eq(old)      
    end

    it "should update on destroy" do
      node = Factory(:node)
      old = CacheVersion.section_node_updated_at
      sleep(1)
      node.destroy
      expect(CacheVersion.section_node_updated_at).not_to eq(old)      
    end
  end
  
  describe '.summary_html' do
    let(:node) { FactoryGirl.create(:node) }
    it 'should return html' do
      node.summary = "# foo"
      expect(node.summary_html).to eq "<h1>foo</h1>\n"
    end
    
    it 'should expire cache on node update' do
      node.summary_html
      node.summary = "# dar"
      node.save
      node.reload
      expect(node.summary_html).to eq "<h1>dar</h1>\n"
    end
  end

end
