require 'spec_helper'

describe Site do
  let(:site_node) { Factory :site_node }

  it "can add favicon default when it not provide" do
    site = Site.create(:name => "Foo bar", :url => "http://foobar.com", :site_node => site_node)
    site.favicon_url.should == "http://www.google.com/profiles/c/favicons?domain=foobar.com"
  end

  it "can add http:// to url field when it not profide" do
    site = Site.create(:name => "Foo bar 3", :url => "foobar3.com", :site_node => site_node)
    site.url.should == "http://foobar3.com"
  end
  
  it "should clean url to only domain" do
    site = Factory(:site, :url => "http://bar1.com")
    site.reload.url.should == "http://bar1.com"
    site = Factory(:site, :url => "https://bar2.com")
    site.reload.url.should == "http://bar2.com"
    site = Factory(:site, :url => "http://bar3.com/")
    site.reload.url.should == "http://bar3.com"
    site = Factory(:site, :url => "bar4.com")
    site.reload.url.should == "http://bar4.com"
    site = Factory(:site, :url => "bar5.com/")
    site.reload.url.should == "http://bar5.com"
    site = Factory(:site, :url => "http://bar6.com/bar")
    site.reload.url.should == "http://bar6.com/bar"
  end
  
  it "should not add again when url was deleted" do
    site =  Factory(:site, :url => "google.com")
    site.destroy
    site = Factory.build(:site, :url => "google.com")
    site.should have(1).error_on(:url)
    site = Factory.build(:site, :url => "google.com/")
    site.should have(1).error_on(:url)
    site = Factory.build(:site, :url => "http://google.com")
    site.should have(1).error_on(:url)
  end
end
