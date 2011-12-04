require 'spec_helper'

describe Site do
  let(:site_node) { Factory :site_node }
  
  it "can add favicon default when it not provide" do
    site = Site.create(:name => "Foo bar", :url => "http://foobar.com", :site_node => site_node)
    site.favicon.should == "http://www.google.com/profiles/c/favicons?domain=foobar.com"
    
    site = Site.create(:name => "Foo bar 1", :url => "http://foobar1.com", :favicon => "http://aaa.com", :site_node => site_node)
    site.favicon.should == "http://aaa.com"
    
    site = Site.create(:name => "Foo bar 2", :url => "http://foobar2.com", :favicon => "aaa.com", :site_node => site_node)
    site.favicon.should == "http://aaa.com"
  end
  
  it "can add http:// to url field when it not profide" do
    site = Site.create(:name => "Foo bar 3", :url => "foobar3.com", :site_node => site_node)
    site.url.should == "http://foobar3.com"
  end
end
