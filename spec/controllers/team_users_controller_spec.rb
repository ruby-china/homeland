# frozen_string_literal: true

require "rails_helper"

describe TeamUsersController, type: :controller do
  let(:team) { create :team }
  let(:user) { create(:user) }
  let(:team_owner) { create(:team_owner, team: team, user: user) }
  let(:team_member) { create(:team_member, team: team, user: user) }

  describe "index" do
    it "should work" do
      get :index, params: { user_id: team.login }
      assert_equal 200, response.status
      assert_equal true, response.body.include?("成员列表")
    end

    context "Normal user" do
      it "should not have invite button" do
        sign_in user
        get :index, params: { user_id: team.login }
        assert_equal 200, response.status
        assert_equal false, response.body.include?("/people/new")
      end
    end

    context "Member" do
      it "should not have invite button" do
        sign_in team_member.user
        get :index, params: { user_id: team.login }
        assert_equal 200, response.status
        assert_equal false, response.body.include?("邀请成员")
        assert_equal false, response.body.include?("/people/new")
      end
    end

    context "Owner" do
      it "should have invite button" do
        sign_in team_owner.user
        get :index, params: { user_id: team.login }
        assert_equal 200, response.status
        assert_equal true, response.body.include?("邀请成员")
        assert_equal true, response.body.include?("/people/new")
      end
    end
  end

  describe "new" do
    context "Owner" do
      it "should work" do
        sign_in team_owner.user
        get :new, params: { user_id: team.login }
        assert_equal 200, response.status
      end
    end

    context "Member" do
      it "should work" do
        sign_in team_member.user
        get :new, params: { user_id: team.login }
        assert_redirected_to root_path
      end
    end
  end

  describe "create" do
    context "Owner" do
      it "should work" do
        user = create(:user)
        sign_in team_owner.user

        team_user = {
          login: user.login,
          role: :member
        }
        post :create, params: { user_id: team.login, team_user: team_user }
        assert_redirected_to user_team_users_path(team)

        team_user = team.team_users.last
        assert_equal user.id, team_user.user_id
        assert_equal "member", team_user.role
        assert_equal true, team_user.pendding?
      end
    end
  end

  describe "edit" do
    let(:team_user) { create(:team_member, team: team) }

    it "Owner should work" do
      sign_in team_owner.user
      get :edit, params: { user_id: team.login, id: team_user.id }
      assert_equal 200, response.status
    end

    it "Member should not open" do
      sign_in team_member.user
      get :edit, params: { user_id: team.login, id: team_user.id }
      assert_redirected_to root_path
    end
  end

  describe "update" do
    let(:team_user) { create(:team_member, team: team) }

    it "Owner should work" do
      sign_in team_owner.user
      params = {
        user_id: 123,
        role: :owner
      }
      put :update, params: { user_id: team.login, id: team_user.id, team_user: params }
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
      get :edit, params: { user_id: team.login, id: team_user.id, team_user: params }
      assert_redirected_to root_path
    end
  end

  describe "Show, Accept, Reject" do
    let(:team_user) { create(:team_member, team: team, status: :pendding) }

    it "Owner should work" do
      sign_in team_user.user

      get :show, params: { user_id: team.login, id: team_user.id }
      assert_equal 200, response.status

      put :accept, params: { user_id: team.login, id: team_user.id }
      team_user.reload
      assert_equal true, team_user.accepted?
      assert_redirected_to user_team_users_path(team)

      get :show, params: { user_id: team.login, id: team_user.id }
      assert_redirected_to user_team_users_path(team)

      put :reject, params: { user_id: team.login, id: team_user.id }
      assert_redirected_to user_team_users_path(team)
      assert_nil team.team_users.find_by_id(team_user.id)
    end

    it "Member should not open" do
      sign_in team_owner.user
      get :show, params: { user_id: team.login, id: team_user.id }
      assert_redirected_to root_path

      put :accept, params: { user_id: team.login, id: team_user.id }
      assert_redirected_to root_path

      put :reject, params: { user_id: team.login, id: team_user.id }
      assert_redirected_to root_path
    end
  end
end
