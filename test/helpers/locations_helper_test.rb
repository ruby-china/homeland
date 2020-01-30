# frozen_string_literal: true

require "test_helper"

class LocationsHelperTest < ActionView::TestCase
  include ApplicationHelper

  test "should location_name_tag work with string" do
    assert_equal link_to("chengdu", location_users_path("chengdu")), location_name_tag("chengdu")
  end

  test "should location_name_tag work with Location instance" do
    location = create(:location)
    assert_equal link_to(location.name, location_users_path(location.name)), location_name_tag(location)
  end
end
