# frozen_string_literal: true

require "test_helper"

class ApplicationRecordTest < ActiveSupport::TestCase
  test "should have recent scope method" do
    monkey = Monkey.create(name: "Caesar", id: 1)
    ghost = Monkey.create(name: "Wukong", id: 2)

    assert_equal [ghost, monkey], Monkey.recent.to_a
  end

  test "should have exclude_ids scope method" do
    ids = Array(1..10)
    ids.each { |i| Monkey.create(name: "entry##{i}", id: i) }

    result1 = Monkey.exclude_ids(ids.to(4).map(&:to_s)).map(&:name)
    result2 = Monkey.exclude_ids(ids.from(5)).map(&:name)

    assert_equal ids.from(5).map { |i| "entry##{i}" }, result1
    assert_equal ids.to(4).map { |i| "entry##{i}" }, result2
  end

  test "should have find_by_id class methods" do
    monkey = Monkey.create(name: "monkey", id: 1)
    assert_equal monkey, Monkey.find_by_id(1)
    assert_equal monkey, Monkey.find_by_id("1")
    assert_nil Monkey.find_by_id(2)
  end

  test "should have by_week method" do
    Monkey.create(name: "Caesar", created_at: 2.weeks.ago.utc)
    Monkey.create(name: "Caesar1", created_at: 3.days.ago.utc)
    Monkey.create(name: "Caesar1", created_at: Time.now.utc)
    assert_equal 2, Monkey.by_week.count
  end
end
