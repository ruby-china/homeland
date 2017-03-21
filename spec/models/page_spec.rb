require 'rails_helper'

describe Page, type: :model do
  it 'slug has check format' do
    page = Page.create(title: 'Foo bar', slug: 'foo.bar')
    expect(page.errors[:slug].size).to eq(1)

    page = Page.create(title: 'Foo bar', slug: 'foo-bar')
    expect(page.errors[:slug].size).to_not eq(1)

    page = Page.create(title: 'Foo bar', slug: 'foo_bar')
    expect(page.errors[:slug].size).to_not eq(1)

    page = Page.create(title: 'Foo bar', slug: 'foo-bar-1')
    expect(page.errors[:slug].size).to_not eq(1)
  end

  describe '.to_param' do
    let(:page) { create(:page, slug: 'foo') }

    it { expect(page.to_param).to eq 'foo' }
  end

  describe 'Search methods' do
    let(:p) { create :page }
    describe '.indexed_changed?' do
      it 'title changed work' do
        expect(p.indexed_changed?).to eq false
        p.title = p.title + '1'
        expect(p.indexed_changed?).to eq true
      end

      it 'slug changed work' do
        expect(p.indexed_changed?).to eq false
        p.body = p.body + '1'
        expect(p.indexed_changed?).to eq true
      end

      it 'text changed work' do
        expect(p.indexed_changed?).to eq false
        p.slug = p.slug + '1'
        expect(p.indexed_changed?).to eq true
      end

      it 'other changed work' do
        expect(p.indexed_changed?).to eq false
        p.comments_count = p.comments_count + 1
        expect(p.indexed_changed?).to eq false
      end
    end
  end
end
