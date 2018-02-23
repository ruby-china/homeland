# frozen_string_literal: true

require "rails_helper"

describe Location, type: :model do
  before(:each) do
    @location = create(:location, name: "foo")
  end

  it "should validates_uniqueness_of :name ignore case" do
    record = Location.create(name: "FoO")
    expect(record.errors[:name].size).to eq(1)
  end

  it "should find_by_name strip left/right space and ignore case" do
    item = Location.location_find_by_name("Foo ")
    expect(item.id).to eq(@location.id)
    item1 = Location.location_find_by_name("FOO")
    expect(item1.id).to eq(@location.id)
  end

  it "should find_by_name will result exist item" do
    item = Location.location_find_or_create_by_name(@location.name)
    expect(item.id).to eq(@location.id)
  end

  it "should find_by_name will create new item when it not exist" do
    item = Location.location_find_or_create_by_name("Beijing")
    expect(item.id).not_to eq(nil)
    expect(item.name).to eq("Beijing".downcase)
  end
end
