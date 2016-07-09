require 'rails_helper'

describe TeamUsersController, type: :controller do
  let(:team) { create :team }
  let(:user) { create(:user) }
  let(:team_owner) { create(:team_owner, team: team, user: user) }
  let(:team_member) { create(:team_member, team: team, user: user) }

  describe 'index' do
    it 'should work' do
      get :index, params: { user_id: team.login }
      expect(response).to be_success
      expect(response.body).to match(/成员列表/)
    end

    context 'Normal user' do
      it 'should not have invite button' do
        sign_in user
        get :index, params: { user_id: team.login }
        expect(response).to be_success
        expect(response.body).not_to match(/\/people\/new/)
      end
    end

    context 'Member' do
      it 'should not have invite button' do
        sign_in team_member.user
        get :index, params: { user_id: team.login }
        expect(response).to be_success
        expect(response.body).not_to match(/邀请成员/)
        expect(response.body).not_to match(/\/people\/new/)
      end
    end

    context 'Owner' do
      it 'should have invite button' do
        sign_in team_owner.user
        get :index, params: { user_id: team.login }
        expect(response).to be_success
        expect(response.body).to match(/邀请成员/)
        expect(response.body).to match(/\/people\/new/)
      end
    end
  end

  describe 'new' do
    context 'Owner' do
      it 'should work' do
        sign_in team_owner.user
        get :new, params: { user_id: team.login }
        expect(response).to be_success
      end
    end

    context 'Member' do
      it 'should work' do
        sign_in team_member.user
        get :new, params: { user_id: team.login }
        expect(response).to redirect_to topics_path
      end
    end
  end

  describe 'create' do
    context 'Owner' do
      it 'should work' do
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
end
