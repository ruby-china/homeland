# coding: utf-8
require "spec_helper"

describe LocationsHelper do
  it "should location_name_tag work with string" do
    helper.location_name_tag("chengdu").should == link_to("chengdu", location_users_path("chengdu"))
  end
  
  it "should location_name_tag work with Location instance" do
    location = Factory(:location)
    helper.location_name_tag(location).should == link_to(location.name, location_users_path(location.name))
  end
end