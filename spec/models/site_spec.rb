require 'rails_helper'

describe Site, :type => :model do
  let(:site_node) { Factory :site_node }

  it "can add favicon default when it not provide" do
    site = Site.create(:name => "Foo bar", :url => "http://foobar.com", :site_node => site_node)
    expect(site.favicon_url).to eq("http://www.google.com/profiles/c/favicons?domain=foobar.com")
  end

  it "can add http:// to url field when it not profide" do
    site = Site.create(:name => "Foo bar 3", :url => "foobar3.com", :site_node => site_node)
    expect(site.url).to eq("http://foobar3.com")
  end
  
  it "should clean url to only domain" do
    site = Factory(:site, :url => "http://bar1.com")
    expect(site.reload.url).to eq("http://bar1.com")
    site = Factory(:site, :url => "https://bar2.com")
    expect(site.reload.url).to eq("http://bar2.com")
    site = Factory(:site, :url => "http://bar3.com/")
    expect(site.reload.url).to eq("http://bar3.com")
    site = Factory(:site, :url => "bar4.com")
    expect(site.reload.url).to eq("http://bar4.com")
    site = Factory(:site, :url => "bar5.com/")
    expect(site.reload.url).to eq("http://bar5.com")
    site = Factory(:site, :url => "http://bar6.com/bar")
    expect(site.reload.url).to eq("http://bar6.com/bar")
  end
  
  it "should not add again when url was deleted" do
    site =  Factory(:site, :url => "google.com")
    site.destroy
    site = Factory.build(:site, :url => "google.com")
    site.valid?
    expect(site.errors[:url].size).to eq(1)
    site = Factory.build(:site, :url => "google.com/")
    site.valid?
    expect(site.errors[:url].size).to eq(1)
    site = Factory.build(:site, :url => "http://google.com")
    site.valid?
    expect(site.errors[:url].size).to eq(1)
  end
end
