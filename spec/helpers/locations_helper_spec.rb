# frozen_string_literal: true

require "rails_helper"

describe LocationsHelper, type: :helper do
  it "should location_name_tag work with string" do
    assert_equal link_to("chengdu", location_users_path("chengdu")), helper.location_name_tag("chengdu")
  end

  it "should location_name_tag work with Location instance" do
    location = create(:location)
    assert_equal link_to(location.name, location_users_path(location.name)), helper.location_name_tag(location)
  end
end
