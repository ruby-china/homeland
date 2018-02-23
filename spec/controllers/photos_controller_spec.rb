# frozen_string_literal: true

require "rails_helper"

describe PhotosController, type: :controller do
  let(:user) { create(:user) }
  let(:file) { fixture_file_upload("test.png") }

  it "create success for valid image" do
    sign_in user
    post :create, params: { file: file }
    expect(response).to have_http_status(200)
    json = JSON.parse(response.body)
    expect(json["ok"]).to be_truthy
    expect(json["url"]).to match(Regexp.new("/uploads/photo/#{Date.today.year}/[a-zA-Z0-9\\-]+.png!large"))
  end

  it "create failure for blank data" do
    sign_in user
    post :create
    expect(response).not_to have_http_status(200)
    expect(response.status).to eq(400)
    json = JSON.parse(response.body)
    expect(json["ok"]).to be_falsey
    expect(json["url"]).to be_blank
  end

  it "create failure for save error" do
    allow_any_instance_of(Photo).to receive(:save).and_return(false)
    sign_in user
    post :create, params: { file: file }
    expect(response).to have_http_status(200)
    json = JSON.parse(response.body)
    expect(json["ok"]).to be_falsey
    expect(json["url"]).to be_blank
  end
end
