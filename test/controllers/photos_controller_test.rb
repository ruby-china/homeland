# frozen_string_literal: true

require "spec_helper"

describe PhotosController do
  let(:user) { create(:user) }
  let(:file) { fixture_file_upload("test.png", "image/png") }

  it "POST /photos success for valid image" do
    sign_in user
    assert_equal "image/png", file.content_type
    post photos_path, params: {file: file}
    assert_equal 200, response.status
    assert_equal true, response.parsed_body["ok"]
    assert_match Regexp.new("/uploads/photo/#{user.login}/[a-zA-Z0-9\\-]+.png!large"), response.parsed_body["url"]
  end

  it "POST /photos failure for blank data" do
    sign_in user
    post photos_path
    refute_equal 200, response.status
    assert_equal 400, response.status
    assert_equal false, response.parsed_body["ok"]
    assert_equal true, response.parsed_body["url"].blank?
  end

  it "POST /photos failure for save error" do
    Photo.any_instance.stubs(:save).returns(false)
    sign_in user
    post photos_path, params: {file: file}
    assert_equal 400, response.status
    assert_equal false, response.parsed_body["ok"]
    assert_equal true, response.parsed_body["url"].blank?
    assert_equal String, response.parsed_body["message"].class
  end
end
