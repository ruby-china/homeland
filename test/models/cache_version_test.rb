# frozen_string_literal: true

require "test_helper"

class CacheVersionTest < ActiveSupport::TestCase
  test "set / get" do
    t = Time.now.to_f.to_s
    CacheVersion.topic_last_suggested_at = t
    assert_equal t, CacheVersion.topic_last_suggested_at
    t1 = Time.now.to_f.to_s
    CacheVersion.topic_last_suggested_at = t1
    assert_equal t1, CacheVersion.topic_last_suggested_at
  end

  test "cache_key" do
    assert_equal "cache_version:foo", CacheVersion.cache_key("foo")
  end
end
