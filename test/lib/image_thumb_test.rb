# frozen_string_literal: true

require "test_helper"
require "fileutils"

class Homeland::ImageThumbTest < ActiveSupport::TestCase
  test "pragma: false" do
    image_thumb = Homeland::ImageThumb.new("test", "xs")
    assert_equal false, image_thumb.exists?
  end

  test "pragma: true" do
    FileUtils.mkdir_p(Rails.root.join("public", "uploads"))
    FileUtils.cp Rails.root.join("public", "favicon.png"), Rails.root.join("public", "uploads", "favicon.png")

    image_thumb = Homeland::ImageThumb.new("favicon.png", "large", pragma: true)
    assert_equal true, image_thumb.exists?

    image_thumb = Homeland::ImageThumb.new("favicon.png", "lg", pragma: true)
    assert_equal true, image_thumb.exists?

    image_thumb = Homeland::ImageThumb.new("favicon.png", "md", pragma: true)
    assert_equal true, image_thumb.exists?

    image_thumb = Homeland::ImageThumb.new("favicon.png", "sm", pragma: true)
    assert_equal true, image_thumb.exists?

    image_thumb = Homeland::ImageThumb.new("favicon.png", "xs", pragma: true)
    assert_equal true, image_thumb.exists?

    image_thumb = Homeland::ImageThumb.new("favicon.png", "other", pragma: true)
    assert_equal true, image_thumb.exists?
  end
end
