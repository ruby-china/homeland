# frozen_string_literal: true

require "test_helper"

class MarkdownBodyTest < ActiveSupport::TestCase
  include ActiveJob::TestHelper

  test "body_html" do
    topic = Topic.new(body: "各类系统总会或多或少的需要一些**赞、收藏、关注/订阅**等功能。\n\n每次我们都要重新开发么？不！那不是 DRY 的风格。采用 Active Record 多态关联（Polymorphic Association）的方式存储各种类型的动作数据，例如：赞、喜欢、收藏、关注、订阅、屏蔽（靠你的想象，还可以干更多的事情）等等。")
    assert_html_equal "<p>各类系统总会或多或少的需要一些<strong>赞、收藏、关注/订阅</strong>等功能。</p><p>每次我们都要重新开发么？不！那不是 DRY 的风格。采用 Active Record 多态关联（Polymorphic Association）的方式存储各种类型的动作数据，例如：赞、喜欢、收藏、关注、订阅、屏蔽（靠你的想象，还可以干更多的事情）等等。</p>", topic.body_html
    assert_equal "各类系统总会或多或少的需要一些赞、收藏、关注/订阅等功能。 每次我们都要重新开发么？不！那不是 DRY 的风格。采用 Active Record 多态关联（Polymorphic Association）的方式存储各种类型的动作数据，...", topic.description
  end
end
