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
      node.update(summary: "foo\n\nbar")
      expect(node.collapse_summary?).to eq false
      node.update(summary: "foo\n\nbar\n\ndar")
      expect(node.collapse_summary?).to eq true
      node.update(summary: "foo\n\n- bar\n- dar")
      expect(node.collapse_summary?).to eq true
    end
  end
end
