# frozen_string_literal: true

require "spec_helper"

describe TeamUsersController do
  let(:team) { create :team }
  let(:user) { create(:user) }
  let(:team_owner) { create(:team_owner, team: team, user: user) }
  let(:team_member) { create(:team_member, team: team, user: user) }

  describe "GET /team_users" do
    it "should work" do
      get user_team_users_path(team)
      assert_equal 200, response.status
      assert_equal true, response.body.include?("Members")
    end

    describe "Normal user" do
      it "should not have invite button" do
        sign_in user
        get user_team_users_path(team)
        assert_equal 200, response.status
        assert_equal false, response.body.include?("/people/new")
      end
    end

    describe "Member" do
      it "should not have invite button" do
        sign_in team_member.user
        get user_team_users_path(team)
        assert_equal 200, response.status
        assert_equal false, response.body.include?("Add a member")
        assert_equal false, response.body.include?("/people/new")
      end
    end

    describe "Owner" do
      it "should have invite button" do
        sign_in team_owner.user
        get user_team_users_path(team)
        assert_equal 200, response.status
        assert_equal true, response.body.include?("Add a member")
        assert_equal true, response.body.include?("/people/new")
      end
    end
  end

  describe "GET /team_users/new" do
    it "Owner should work" do
      sign_in team_owner.user
      get new_user_team_user_path(team)
      assert_equal 200, response.status
    end

    it "Member should work" do
      sign_in team_member.user
      get new_user_team_user_path(team)
      assert_redirected_to root_path
    end
  end

  it "POST /team_users" do
    user = create(:user)
    sign_in team_owner.user

    team_user = {
      login: user.login,
      role: :member
    }
    post user_team_users_path(team), params: { team_user: team_user }
    assert_redirected_to user_team_users_path(team)

    team_user = team.team_users.last
    assert_equal user.id, team_user.user_id
    assert_equal "member", team_user.role
    assert_equal true, team_user.pendding?
  end

  describe "GET /team_users/:id/edit" do
    let(:team_user) { create(:team_member, team: team) }

    it "Owner should work" do
      sign_in team_owner.user
      get edit_user_team_user_path(team, team_user)
      assert_equal 200, response.status
    end

    it "Member should not open" do
      sign_in team_member.user
      get edit_user_team_user_path(team, team_user)
      assert_redirected_to root_path
    end
  end

  describe "PUT /team_users/:id" do
    let(:team_user) { create(:team_member, team: team) }

    it "Owner should work" do
      sign_in team_owner.user
      params = {
        user_id: 123,
        role: :owner
      }
      put user_team_user_path(team, team_user), params: { team_user: params }
      old_user_id = team_user.user_id
      team_user.reload
      assert_equal old_user_id, team_user.user_id
      assert_equal true, team_user.owner?
      assert_redirected_to user_team_users_path(team)
    end

    it "Member should not open" do
      user = create(:user)
      sign_in team_member.user
      params = {
        login: user.login,
        role: :member
      }
      get edit_user_team_user_path(team, team_user), params: { team_user: params }
      assert_redirected_to root_path
    end
  end

  describe "Show, Accept, Reject" do
    let(:team_user) { create(:team_member, team: team, status: :pendding) }

    it "Owner should work" do
      sign_in team_user.user

      get user_team_user_path(team, team_user)
      assert_equal 200, response.status

      post accept_user_team_user_path(team, team_user)
      assert_redirected_to user_team_users_path(team)
      team_user.reload
      assert_equal true, team_user.accepted?

      get user_team_user_path(team, team_user)
      assert_redirected_to user_team_users_path(team)

      post reject_user_team_user_path(team, team_user)
      assert_redirected_to user_team_users_path(team)
      assert_nil team.team_users.find_by_id(team_user.id)
    end

    it "Member should not open" do
      sign_in team_owner.user
      get user_team_user_path(team, team_user)
      assert_redirected_to root_path

      post accept_user_team_user_path(team, team_user)
      assert_redirected_to root_path

      post reject_user_team_user_path(team, team_user)
      assert_redirected_to root_path
    end
  end
end
