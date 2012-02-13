require "spec_helper"

describe UsersCell do
  before(:each) do
    @user = Factory :user
  end

  describe "active_users" do
    it "should render active users" do
      render_cell(:users, :active_users).should have_css("div.name", :count => 1)
    end

    it "should limit the number of users rendered" do
      30.times { Factory :user }
      render_cell(:users, :active_users).should have_css("div.name", :count => 20)
    end
  end

  describe "recent_join_users" do
    it "should render recent users" do
      render_cell(:users, :recent_join_users).should have_css("div.name", :count => 1)
    end

    it "should limit the number of users rendered" do
      30.times { Factory :user }
      render_cell(:users, :recent_join_users).should have_css("div.name", :count => 20)
    end
  end
end
