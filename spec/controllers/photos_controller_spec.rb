# frozen_string_literal: true

require "rails_helper"

describe PhotosController, type: :controller do
  let(:user) { create(:user) }
  let(:file) { fixture_file_upload("test.png") }

  it "create success for valid image" do
    sign_in user
    post :create, params: { file: file }
    assert_equal 200, response.status
    assert_equal true, response.parsed_body["ok"]
    assert_match Regexp.new("/uploads/photo/#{Date.today.year}/[a-zA-Z0-9\\-]+.png!large"), response.parsed_body["url"]
  end

  it "create failure for blank data" do
    sign_in user
    post :create
    refute_equal 200, response.status
    assert_equal 400, response.status
    assert_equal false, response.parsed_body["ok"]
    assert_equal true, response.parsed_body["url"].blank?
  end

  it "create failure for save error" do
    allow_any_instance_of(Photo).to receive(:save).and_return(false)
    sign_in user
    post :create, params: { file: file }
    assert_equal 400, response.status
    assert_equal false, response.parsed_body["ok"]
    assert_equal true, response.parsed_body["url"].blank?
  end
end
