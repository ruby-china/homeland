# frozen_string_literal: true

require "test_helper"

class Homeland::HtmlTest < ActiveSupport::TestCase
  test "plain" do
    html = read_file("plain.html")
    expected = read_file("plain.txt")
    assert_equal expected, Homeland::Html.plain(html)
  end
end
