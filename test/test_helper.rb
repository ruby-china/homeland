# frozen_string_literal: true

ENV["RAILS_ENV"] = "test"
ENV["upload_provider"] = "file"

# Mock to enable all Omniauth providers
ENV["github_api_key"] = "fake-key"
ENV["twitter_api_key"] = "fake-key"
ENV["wechat_api_key"] = "fake-key"

require_relative "../config/environment"
require "rails/test_help"
require "minitest/autorun"
require "mocha/minitest"
require "sidekiq/testing"
require_relative "./support/model"

FileUtils.mkdir_p(Rails.root.join("tmp/cache"))

OmniAuth.config.test_mode = true
FactoryBot.use_parent_strategy = false

class ActiveSupport::TestCase
  include FactoryBot::Syntax::Methods

  parallelize

  parallelize_setup do |worker|
    setup_test_db!
  end

  setup do
    Setting.stubs(:captcha_enable?).returns(true)
    Setting.stubs(:topic_create_limit_interval).returns("")
    Setting.stubs(:topic_create_hour_limit_count).returns("")
  end

  teardown do
    Rails.cache.clear
  end

  def read_file(fname)
    load_file(fname).read.strip
  end

  def load_file(fname)
    File.open(Rails.root.join("test", "fixtures", fname))
  end

  def assert_html_equal(excepted, html)
    assert_equal excepted.strip.gsub(/>\s+</, "><"), html.strip.gsub(/>\s+</, "><")
  end

  def assert_has_keys(collection, *keys)
    keys.each do |key|
      assert_equal true, collection.has_key?(key)
    end
  end

  def assert_includes_all(collection, *other)
    other.each do |item|
      assert_includes collection, item
    end
  end

  def assert_not_includes_any(collection, *other)
    other.each do |item|
      assert_not_includes collection, item
    end
  end

  def fixture_file_upload(name, content_type = "image/png")
    ActionDispatch::Http::UploadedFile.new(
      filename: name,
      type: content_type,
      tempfile: File.new(File.join("test", "fixtures", "files", name))
    )
  end
end

class ActionView::TestCase
  def sign_in(user)
    @user = user
  end

  def sign_out
    @user = nil
  end

  def current_user
    @user
  end
end

class ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  def assert_require_user(&block)
    yield block
    assert_equal 302, response.status
    assert_match(/\/account\/sign_in/, response.headers["Location"])
  end

  def assert_signed_in
    get setting_path
    assert_equal 200, response.status
    assert_select "a[href='/account/sign_out']"
  end
end
