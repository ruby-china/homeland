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
end
