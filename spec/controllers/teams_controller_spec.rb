require 'rails_helper'

describe TeamsController, type: :controller do
  let(:user) { create :wiki_editor }
  describe 'index' do
    it 'should work' do
      get :index
      expect(response).to be_success
    end
  end

  describe 'new' do
    it 'should work' do
      sign_in user
      get :new
      expect(response).to be_success
      expect(response.body).to match(/创建公司／组织/)
    end
  end

  describe 'create' do
    let(:team) { build(:team) }
    it 'should work' do
      sign_in user
      params = {
        team: {
          login: team.login,
          name: team.name,
          email: team.email
        }
      }
      expect do
        post :create, params: params
      end.to change(Team, :count).by(1)
    end
  end
end
