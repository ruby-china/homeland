require "spec_helper"

describe Admin::UsersController do
  before do
    sign_in create(:admin)
  end

  it "GET /admin/users" do
    get admin_users_path
    assert_equal 200, response.status
  end

  it "GET /admin/users/:id/edit" do
    user = create :user
    get edit_admin_user_path(user.id)
    assert_equal 200, response.status
  end
end
