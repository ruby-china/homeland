# frozen_string_literal: true

require "test_helper"

class Homeland::SearchText < ActiveSupport::TestCase
  test "initialize" do
    @search = Homeland::Search.new("(Ruby)语言!")
    assert_equal ["Ruby", "语言"], @search.terms
    assert_equal "Ruby 语言", @search.term
    assert_equal "TO_TSQUERY('simple', 'Ruby:* & 语言:*')", @search.ts_query
  end

  test "empty term" do
    @search = Homeland::Search.new("")
    assert_equal "", @search.term
    assert_equal "TO_TSQUERY('simple', '')", @search.ts_query
  end

  test "prepare_data" do
    assert_equal "Ruby 语言", Homeland::Search.prepare_data("Ruby语言")
  end
end
