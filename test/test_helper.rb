# frozen_string_literal: true

ENV["RAILS_ENV"] = "test"

require_relative "../config/environment"
require "minitest/autorun"
require "mocha/minitest"
require "rails/test_help"
require "sidekiq/testing"
require "simplecov"

SimpleCov.start
if ENV["CI"] == "true"
  require "codecov"
  SimpleCov.formatter = SimpleCov::Formatter::Codecov
end

FileUtils.mkdir_p(Rails.root.join("tmp/cache"))


OmniAuth.config.test_mode = true
Devise.stretches = 1
Rails.logger.level = 4
FactoryBot.use_parent_strategy = false
DatabaseCleaner.orm = :active_record
DatabaseCleaner.strategy = :truncation


ActiveRecord::Base.connection.create_table(:monkeys, force: true) do |t|
  t.string :name
  t.integer :user_id
  t.integer :comments_count
  t.timestamps null: false
end

ActiveRecord::Base.connection.create_table(:commentable_pages, force: true) do |t|
  t.string :name
  t.integer :user_id
  t.integer :comments_count, default: 0, null: false
  t.timestamps null: false
end

class CommentablePage < ApplicationRecord
end

class Monkey < ApplicationRecord
end

class ActiveSupport::TestCase
  include FactoryBot::Syntax::Methods

  setup do
    Setting.stubs(:topic_create_limit_interval).returns("")
    Setting.stubs(:topic_create_hour_limit_count).returns("")

    # Database cleaner
    DatabaseCleaner.clean
    Rails.cache.clear

    Monkey.delete_all
    CommentablePage.delete_all
  end

  def read_file(fname)
    load_file(fname).read.strip
  end

  def load_file(fname)
    File.open(Rails.root.join("test", "factories", fname))
  end

  def assert_html_equal(excepted, html)
    assert_equal excepted.strip.gsub(/>[\s]+</, "><"), html.strip.gsub(/>[\s]+</, "><")
  end
end

class ActionView::TestCase
  include Devise::Test::IntegrationHelpers
end


class ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers
end