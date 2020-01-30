# frozen_string_literal: true

require "rails_helper"

describe Location, type: :model do
  before(:each) do
    @location = create(:location, name: "foo")
  end

  it "should validates_uniqueness_of :name ignore case" do
    record = Location.create(name: "FoO")
    assert_equal 1, record.errors[:name].size
  end

  it "should find_by_name strip left/right space and ignore case" do
    item = Location.location_find_by_name("Foo ")
    assert_equal @location.id, item.id
    item1 = Location.location_find_by_name("FOO")
    assert_equal @location.id, item1.id
  end

  it "should find_by_name will result exist item" do
    item = Location.location_find_or_create_by_name(@location.name)
    assert_equal @location.id, item.id
  end

  it "should find_by_name will create new item when it not exist" do
    item = Location.location_find_or_create_by_name("Beijing")
    refute_equal nil, item.id
    assert_equal "Beijing".downcase, item.name
  end
end
