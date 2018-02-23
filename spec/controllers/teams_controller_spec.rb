# frozen_string_literal: true

require "rails_helper"

describe TeamsController, type: :controller do
  let(:user) { create :wiki_editor }
  describe "index" do
    it "should work" do
      get :index
      expect(response).to have_http_status(200)
    end
  end

  describe "show" do
    let(:team) { create(:team) }
    it "should work" do
      get :show, params: { id: team }
      expect(response).to redirect_to(user_path(team))
    end
  end

  describe "new" do
    it "should work" do
      sign_in user
      get :new
      expect(response).to have_http_status(200)
      expect(response.body).to match(/创建公司／组织/)
    end
  end

  describe "create" do
    let(:team) { build(:team) }
    it "should work" do
      sign_in user
      expect do
        post :create, params: { team: { login: team.login, name: team.name, email: team.email } }
      end.to change(Team, :count).by(1)
    end

    it "should render new after save failure" do
      sign_in user
      allow_any_instance_of(Team).to receive(:save).and_return(false)
      post :create, params: { team: { login: team.login, name: team.name, email: team.email } }
      expect(response).to have_http_status(200)
    end
  end

  describe "update" do
    let(:team) { create(:team) }
    let!(:team_owner) { create(:team_owner, team: team, user: user) }
    it "should work" do
      sign_in user
      put :update, params: { id: team.login, team: { login: team.login, name: team.name, email: team.email } }
      expect(response).to redirect_to(edit_team_path(team))
    end

    it "should render edit after save failure" do
      sign_in user
      allow_any_instance_of(Team).to receive(:update).and_return(false)
      put :update, params: { id: team.login, team: { login: team.login, name: team.name, email: team.email } }
      expect(response).to have_http_status(200)
    end
  end
end
