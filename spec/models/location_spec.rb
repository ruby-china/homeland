# coding: utf-8
require "spec_helper"

describe Location do
  before(:each) do
    @location = Factory(:location,:name => 'foo')
  end
  
  it "should validates_uniqueness_of :name ignore case" do
    Location.create(:name => "FoO").should have(1).error_on(:name)
  end
  
  it "should find_by_name strip left/right space and ignore case" do
    item = Location.find_by_name("Foo ")
    item.id.should == @location.id
    item1 = Location.find_by_name("FOO")
    item1.id.should == @location.id    
  end
  
  it "should find_by_name will result exist item" do
    item = Location.find_or_create_by_name(@location.name)
    item.id.should == @location.id
  end
  
  it "should find_by_name will create new item when it not exist" do
    item = Location.find_or_create_by_name("东京")
    item.id.should_not == nil
    item.name.should == "东京"
  end
end