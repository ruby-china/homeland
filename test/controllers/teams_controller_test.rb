# frozen_string_literal: true

require "spec_helper"

describe TeamsController do
  let(:user) { create :vip }

  it "GET /teams" do
    get teams_path
    assert_equal 200, response.status
  end

  it "GET /teams/:id" do
    team = create(:team)
    get team_path(team)
    assert_redirected_to user_path(team)
  end

  it "GET /teams/new" do
    sign_in user
    get new_team_path
    assert_equal 200, response.status
    assert_equal true, response.body.include?("New team")
  end

  describe "POST /teams" do
    let(:team) { build(:team) }

    it "should work" do
      sign_in user
      post teams_path, params: { team: { login: team.login, name: team.name, email: team.email } }
      new_team = Team.last
      assert_redirected_to edit_team_path(new_team)

      assert_equal team.login, new_team.login
      assert_equal team.name, new_team.name
      assert_equal team.email, new_team.email
    end
  end

  describe "PUT /teams/:id" do
    let(:team) { create(:team) }

    it "should work" do
      sign_in user

      team_owner = create(:team_owner, team: team, user: user)

      put team_path(team), params: { team: { login: team.login, name: team.name, email: team.email } }
      assert_redirected_to edit_team_path(team)
    end
  end
end
