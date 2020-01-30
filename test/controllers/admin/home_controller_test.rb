# frozen_string_literal: true

require "rails_helper"

describe Admin::HomeController do
  let(:user) { create :user }
  let(:admin) { create :admin }

  describe "GET /admin" do
    it "should open with admin user" do
      sign_in admin
      get admin_root_path
      assert_equal 200, response.status
    end

    it "should 404 with non admin user" do
      sign_in user
      get admin_root_path
      assert_equal 404, response.status
    end
  end
end
