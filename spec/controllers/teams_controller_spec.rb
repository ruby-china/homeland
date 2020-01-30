# frozen_string_literal: true

require "rails_helper"

describe TeamsController, type: :controller do
  let(:user) { create :wiki_editor }
  describe "index" do
    it "should work" do
      get :index
      assert_equal 200, response.status
    end
  end

  describe "show" do
    let(:team) { create(:team) }
    it "should work" do
      get :show, params: { id: team }
      assert_redirected_to user_path(team)
    end
  end

  describe "new" do
    it "should work" do
      sign_in user
      get :new
      assert_equal 200, response.status
      assert_equal true, response.body.include?("创建公司／组织")
    end
  end

  describe "create" do
    let(:team) { build(:team) }
    it "should work" do
      sign_in user
      post :create, params: { team: { login: team.login, name: team.name, email: team.email } }
      new_team = Team.last
      assert_redirected_to edit_team_path(new_team)

      assert_equal team.login, new_team.login
      assert_equal team.name, new_team.name
      assert_equal team.email, new_team.email
    end

    it "should render new after save failure" do
      sign_in user
      allow_any_instance_of(Team).to receive(:save).and_return(false)
      post :create, params: { team: { login: team.login, name: team.name, email: team.email } }
      assert_equal 200, response.status
    end
  end

  describe "update" do
    let(:team) { create(:team) }
    let!(:team_owner) { create(:team_owner, team: team, user: user) }
    it "should work" do
      sign_in user
      put :update, params: { id: team.login, team: { login: team.login, name: team.name, email: team.email } }
      assert_redirected_to edit_team_path(team)
    end

    it "should render edit after save failure" do
      sign_in user
      allow_any_instance_of(Team).to receive(:update).and_return(false)
      put :update, params: { id: team.login, team: { login: team.login, name: team.name, email: team.email } }
      assert_equal 200, response.status
    end
  end
end
