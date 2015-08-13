require 'rails_helper'

describe Node, type: :model do
  describe 'Validates' do
    it 'should fail saving without specifing a section' do
      node = Node.new
      node.name = 'Cersei'
      node.summary = 'the Queue'
      node.save == false
    end
  end

  describe 'CacheVersion update' do
    let(:old) { 1.minutes.ago }

    it 'should update on save' do
      CacheVersion.section_node_updated_at = old
      Factory(:node)
      expect(CacheVersion.section_node_updated_at).not_to eq(old)
    end

    it 'should update on destroy' do
      node = Factory(:node)
      CacheVersion.section_node_updated_at = old
      node.destroy
      expect(CacheVersion.section_node_updated_at).not_to eq(old)
    end
  end

  describe '.summary_html' do
    let(:node) { FactoryGirl.create(:node) }
    it 'should return html' do
      node.summary = '# foo'
      expect(node.summary_html).to eq "<h1>foo</h1>\n"
    end

    it 'should expire cache on node update' do
      node.summary_html
      node.summary = '# dar'
      node.save
      node.reload
      expect(node.summary_html).to eq "<h1>dar</h1>\n"
    end
  end

  describe '.new_topic_dropdowns' do
    let(:nodes) { FactoryGirl.create_list(:node, 10) }

    before do
      SiteConfig.new_topic_dropdown_node_ids = nodes.collect(&:id).join(',')
    end

    it 'should be 5 for length' do
      expect(Node.new_topic_dropdowns.length).to eq(5)
    end

    it 'should be within site config nodes' do
      expect(nodes).to include(*Node.new_topic_dropdowns)
    end
  end
end
