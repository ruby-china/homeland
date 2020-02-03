# frozen_string_literal: true

require "spec_helper"

class Admin::DashboardsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @admin = create(:admin)
    sign_in @admin
  end

  test "GET /admin without admin" do
    user = create(:user)
    sign_in user
    get admin_root_path
    assert_equal 404, response.status
  end

  test "GET /admin" do
    get admin_root_path
    assert_equal 200, response.status
  end

  test "POST /admin/dashboards/reboot" do
    post reboot_admin_dashboards_path
    assert_redirected_to admin_root_path
  end
end
