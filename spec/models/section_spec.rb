require 'rails_helper'

describe Section, type: :model do
  describe 'CacheVersion update' do
    let(:old) { 1.minutes.ago }
    it 'should update on save' do
      CacheVersion.section_node_updated_at = old
      Factory(:section)
      expect(CacheVersion.section_node_updated_at).not_to eq(old)
    end

    it 'should update on destroy' do
      section = Factory(:section)
      CacheVersion.section_node_updated_at = old
      section.destroy
      expect(CacheVersion.section_node_updated_at).not_to eq(old)
    end
  end
end
