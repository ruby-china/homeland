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

  describe 'Builtin nodes' do
    describe '.no_point' do
      it 'should work' do
        expect(Node.no_point).to be_a(Node)
        expect(Node.no_point.new_record?).to eq false
        expect(Node.no_point.name).to eq 'NoPoint'
        expect(Node.no_point.id).to eq 61
      end
    end

    describe '.job' do
      it 'should work' do
        expect(Node.job).to be_a(Node)
        expect(Node.job.new_record?).to eq false
        expect(Node.job.name).to eq '招聘'
        expect(Node.job.id).to eq 25
      end
    end
  end

  describe 'CacheVersion update' do
    let(:old) { 1.minutes.ago }

    it 'should update on save' do
      CacheVersion.section_node_updated_at = old
      create(:node)
      expect(CacheVersion.section_node_updated_at).not_to eq(old)
    end

    it 'should update on destroy' do
      node = create(:node)
      CacheVersion.section_node_updated_at = old
      node.destroy
      expect(CacheVersion.section_node_updated_at).not_to eq(old)
    end
  end

  describe '.summary_html' do
    let(:node) { create(:node) }
    it 'should return html' do
      node.summary = '# foo'
      expect(node.summary_html).to eq '<h2 id="foo">foo</h2>'
    end

    it 'should expire cache on node update' do
      node.summary_html
      node.summary = '# dar'
      node.save
      node.reload
      expect(node.summary_html).to eq '<h2 id="dar">dar</h2>'
    end
  end

  describe '.collapse_summary?' do
    let(:node) { create(:node) }
    it 'should work' do
      expect(node.collapse_summary?).to eq false
      node.update_attributes(summary: "foo\n\nbar")
      expect(node.collapse_summary?).to eq false
      node.update_attributes(summary: "foo\n\nbar\n\ndar")
      expect(node.collapse_summary?).to eq true
      node.update_attributes(summary: "foo\n\n- bar\n- dar")
      expect(node.collapse_summary?).to eq true
    end
  end

  describe '.new_topic_dropdowns' do
    let(:nodes) { create_list(:node, 10) }

    before do
      Setting.new_topic_dropdown_node_ids = nodes.collect(&:id).join(',')
    end

    it 'should be 5 for length' do
      expect(Node.new_topic_dropdowns.length).to eq(5)
    end

    it 'should be within site config nodes' do
      expect(nodes).to include(*Node.new_topic_dropdowns)
    end
  end
end
