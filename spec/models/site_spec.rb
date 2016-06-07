require 'rails_helper'

describe Site, type: :model do
  let(:site_node) { create :site_node }

  it 'can add favicon default when it not provide' do
    site = Site.create(name: 'Foo bar', url: 'http://foobar.com', site_node: site_node)
    expect(site.favicon_url).to eq('https://favicon.b0.upaiyun.com/ip2/foobar.com.ico')
  end

  it 'can add http:// to url field when it not profide' do
    site = Site.create(name: 'Foo bar 3', url: 'foobar3.com', site_node: site_node)
    expect(site.url).to eq('http://foobar3.com')
  end

  it 'should clean url to only domain' do
    site = create(:site, url: 'http://bar1.com')
    expect(site.reload.url).to eq('http://bar1.com')
    site = create(:site, url: 'https://bar2.com')
    expect(site.reload.url).to eq('http://bar2.com')
    site = create(:site, url: 'http://bar3.com/')
    expect(site.reload.url).to eq('http://bar3.com')
    site = create(:site, url: 'bar4.com')
    expect(site.reload.url).to eq('http://bar4.com')
    site = create(:site, url: 'bar5.com/')
    expect(site.reload.url).to eq('http://bar5.com')
    site = create(:site, url: 'http://bar6.com/bar')
    expect(site.reload.url).to eq('http://bar6.com/bar')
  end

  it 'should not add again when url was deleted' do
    site = create(:site, url: 'google.com')
    site.destroy
    site = build(:site, url: 'google.com')
    site.valid?
    expect(site.errors[:url].size).to eq(1)
    site = build(:site, url: 'google.com/')
    site.valid?
    expect(site.errors[:url].size).to eq(1)
    site = build(:site, url: 'http://google.com')
    site.valid?
    expect(site.errors[:url].size).to eq(1)

    site = create(:site, url: 'test-valid.com')
    site.name = 'Test Valid'
    site.save
    expect(site.errors[:url].size).to eq(0)
    expect(site.name).to eq 'Test Valid'
  end
end
