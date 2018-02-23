# frozen_string_literal: true

require "rails_helper"

describe LocationsHelper, type: :helper do
  it "should location_name_tag work with string" do
    expect(helper.location_name_tag("chengdu")).to eq(link_to("chengdu", location_users_path("chengdu")))
  end

  it "should location_name_tag work with Location instance" do
    location = create(:location)
    expect(helper.location_name_tag(location)).to eq(link_to(location.name, location_users_path(location.name)))
  end
end
