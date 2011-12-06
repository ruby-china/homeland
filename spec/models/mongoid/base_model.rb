require 'spec_helper'

describe Mongoid::BaseModel do
  class Monkey
    include Mongoid::Document
    include Mongoid::BaseModel

    field :name
  end

  it "should have recent scope method" do
    monkey = Monkey.create(:name => "Caesar", :_id => 1)
    ghost = Monkey.create(:name => "Wukong", :_id => 2)

    Monkey.recent.to_a.should == [ghost, monkey]
  end

  it "should have exclude_ids scope method" do
    ids = Array(1..10)
    ids.each { |i| Monkey.create(:name => "entry##{i}", :_id => i) }

    result1 = Monkey.exclude_ids(ids.to(4).map(&:to_s)).map(&:name)
    result2 = Monkey.exclude_ids(ids.from(5)).map(&:name)

    result1.should == ids.from(5).map { |i| "entry##{i}" }
    result2.should == ids.to(4).map { |i| "entry##{i}" }
  end

  it "should have find_by_id class methods" do
    monkey = Monkey.create(:name => "monkey", :_id => 1)
    Monkey.find_by_id(1).should eq(monkey)
    Monkey.find_by_id("1").should eq(monkey)
    Monkey.find_by_id(2).should be_nil
  end
end
