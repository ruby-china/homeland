# frozen_string_literal: true

require "test_helper"

class Setting::LegecyTest < ActiveSupport::TestCase
  test "legecy_envs" do
    assert_equal [], Setting.legecy_envs
    ENV["github_token"] = "foo"
    assert_equal [:github_token], Setting.legecy_envs
  end

  test "legecy_env_instead" do
    assert_equal "github_api_key", Setting.legecy_env_instead(:github_token)
    assert_equal "github_api_secret", Setting.legecy_env_instead(:github_secret)
  end
end
