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
      expect(response).to have_http_status(200)
      expect(response.body).to match(/成员列表/)
    end

    context "Normal user" do
      it "should not have invite button" do
        sign_in user
        get :index, params: { user_id: team.login }
        expect(response).to have_http_status(200)
        expect(response.body).not_to match(/\/people\/new/)
      end
    end

    context "Member" do
      it "should not have invite button" do
        sign_in team_member.user
        get :index, params: { user_id: team.login }
        expect(response).to have_http_status(200)
        expect(response.body).not_to match(/邀请成员/)
        expect(response.body).not_to match(/\/people\/new/)
      end
    end

    context "Owner" do
      it "should have invite button" do
        sign_in team_owner.user
        get :index, params: { user_id: team.login }
        expect(response).to have_http_status(200)
        expect(response.body).to match(/邀请成员/)
        expect(response.body).to match(/\/people\/new/)
      end
    end
  end

  describe "new" do
    context "Owner" do
      it "should work" do
        sign_in team_owner.user
        get :new, params: { user_id: team.login }
        expect(response).to have_http_status(200)
      end
    end

    context "Member" do
      it "should work" do
        sign_in team_member.user
        get :new, params: { user_id: team.login }
        expect(response).to redirect_to root_path
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
        expect do
          post :create, params: { user_id: team.login, team_user: team_user }
        end.to change(team.team_users, :count).by(1)
        expect(response).to redirect_to user_team_users_path(team)
      end
    end
  end

  describe "edit" do
    let(:team_user) { create(:team_member, team: team) }

    it "Owner should work" do
      sign_in team_owner.user
      get :edit, params: { user_id: team.login, id: team_user.id }
      expect(response).to have_http_status(200)
    end

    it "Member should not open" do
      sign_in team_member.user
      get :edit, params: { user_id: team.login, id: team_user.id }
      expect(response).to redirect_to root_path
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
      expect(team_user.user_id).to eq old_user_id
      expect(team_user.owner?).to eq true
      expect(response).to redirect_to user_team_users_path(team)
    end

    it "Member should not open" do
      user = create(:user)
      sign_in team_member.user
      params = {
        login: user.login,
        role: :member
      }
      get :edit, params: { user_id: team.login, id: team_user.id, team_user: params }
      expect(response).to redirect_to root_path
    end
  end

  describe "Show, Accept, Reject" do
    let(:team_user) { create(:team_member, team: team, status: :pendding) }

    it "Owner should work" do
      sign_in team_user.user
      get :show, params: { user_id: team.login, id: team_user.id }
      expect(response).to have_http_status(200)
      put :accept, params: { user_id: team.login, id: team_user.id }
      team_user.reload
      expect(team_user.accepted?).to eq true
      expect(response).to redirect_to user_team_users_path(team)
      get :show, params: { user_id: team.login, id: team_user.id }
      expect(response).to redirect_to user_team_users_path(team)

      expect do
        put :reject, params: { user_id: team.login, id: team_user.id }
      end.to change(team.team_users, :count).by(-1)
      expect(response).to redirect_to user_team_users_path(team)
    end

    it "Member should not open" do
      sign_in team_owner.user
      get :show, params: { user_id: team.login, id: team_user.id }
      expect(response).to redirect_to root_path
      put :accept, params: { user_id: team.login, id: team_user.id }
      expect(response).to redirect_to root_path
      put :reject, params: { user_id: team.login, id: team_user.id }
      expect(response).to redirect_to root_path
    end
  end
end
