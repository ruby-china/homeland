require 'spec_helper'

describe Mongoid::BaseModel do
  class Monkey
    include Mongoid::Document
    include Mongoid::BaseModel
    include Mongoid::Attributes::Dynamic

    field :name
  end
  
  after(:each) do
    Monkey.delete_all
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
  
  it "should have by_week method" do
    Monkey.create(:name => "Caesar", :created_at => 2.weeks.ago.utc)
    Monkey.create(:name => "Caesar1", :created_at => 3.days.ago.utc)
    Monkey.create(:name => "Caesar1", :created_at => Time.now.utc)
    Monkey.by_week.count.should eq(2)
  end
end
