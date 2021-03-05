# frozen_string_literal: true

require "test_helper"

class Homeland::SanitizeTest < ActiveSupport::TestCase
  include ActionView::Helpers::SanitizeHelper

  def assert_sanitize_html(expected, raw)
    assert_equal expected, sanitize(raw, scrubber: Homeland::Sanitize::TOPIC_SCRUBBER)
  end

  test "work relative link" do
    html = '<a href="/foo">foo</a>'
    assert_sanitize_html html, html
  end

  test "work url link" do
    html = '<a href="http://foobar.com/foo">foo</a>'
    assert_sanitize_html html, html
  end

  test "block javascript" do
    assert_sanitize_html "<a>link</a>", '<a href="javascript:alert()">link</a>'
  end

  test "block script" do
    assert_sanitize_html 'alert("");foo', '<script>alert("");</script>foo'
  end

  test "block style" do
    assert_sanitize_html ".body{}foo", "<style>.body{}</style>foo"
  end

  test "block iframe" do
    assert_sanitize_html "", '<iframe src="https://foobar.com"></iframe>'
  end

  test "allow youtube iframe" do
    html = '<span class="embed-responsive embed-responsive-16by9">
    <iframe width="560" height="315" src="https://www.youtube.com/embed/gFQpxAKx_ds" class="embed" frameborder="0" allowfullscreen=""></iframe>
    </span>'
    assert_sanitize_html html, html

    html = '<span class="embed-responsive embed-responsive-16by9">
    <iframe width="560" height="315" src="https://player.vimeo.com/video/159449591" class="embed" frameborder="0" allowfullscreen=""></iframe>
    </span>'
    assert_sanitize_html html, html

    html = '<span class="embed-responsive embed-responsive-16by9">
    <iframe width="560" height="315" src="http://www.youtube.com/embed/gFQpxAKx_ds" class="embed" frameborder="0" allowfullscreen=""></iframe>
    </span>'
    assert_sanitize_html html, html

    html = '<span class="embed-responsive embed-responsive-16by9">
    <iframe width="560" height="315" src="//www.youtube.com/embed/gFQpxAKx_ds" class="embed" frameborder="0" allowfullscreen=""></iframe>
    </span>'
    assert_sanitize_html html, html

    html = '<iframe width="560" height="315" src="//www.youtube.com/aaa" class="embed" frameborder="0" allowfullscreen=""></iframe>'
    assert_sanitize_html "", html
  end

  test "allow youku iframe" do
    html = '<span class="embed-responsive embed-responsive-16by9">
    <iframe width="560" height="315" src="https://player.youku.com/embed/XMjUzMTk4NTk2MA==" class="embed" frameborder="0" allowfullscreen=""></iframe>
    </span>'
    assert_sanitize_html html, html

    html = '<span class="embed-responsive embed-responsive-16by9">
    <iframe width="560" height="315" src="http://player.youku.com/embed/XMjUzMTk4NTk2MA==" class="embed" frameborder="0" allowfullscreen=""></iframe>
    </span>'
    assert_sanitize_html html, html

    html = '<span class="embed-responsive embed-responsive-16by9">
    <iframe width="560" height="315" src="//player.youku.com/embed/XMjUzMTk4NTk2MA==" class="embed" frameborder="0" allowfullscreen=""></iframe>
    </span>'
    assert_sanitize_html html, html

    html = '<iframe width="560" height="315" src="//player.youku.com/XMjUzMTk4NTk2MA==" class="embed" frameborder="0" allowfullscreen=""></iframe>'
    assert_sanitize_html "", html

    html = '<iframe width="560" height="315" src="//www.youku.com/XMjUzMTk4NTk2MA==" class="embed" frameborder="0" allowfullscreen=""></iframe>'
    assert_sanitize_html "", html

    html = '<span class="embed-responsive embed-responsive-16by9">
    <iframe width="560" height="315" src="//player.bilibili.com/player.html?aid=86873549" class="embed" frameborder="0" allowfullscreen=""></iframe>
    </span>'
    assert_sanitize_html html, html
  end

  test "img filter bad" do
    html = '<img src="javascript:alert" class="emoji" width="100" height="100">'
    assert_sanitize_html '<img class="emoji" width="100" height="100">', html
  end

  test "img attrbutes" do
    html = '<img src="/img/a.jpg" class="emoji" width="100" height="100">'
    assert_sanitize_html html, html

    html = '<img src="http://foo.com/img/a.jpg" class="emoji" width="100" height="100">'
    assert_sanitize_html html, html

    html = '<img src="https://foo.com/img/a.jpg" class="emoji" width="100" height="100">'
    assert_sanitize_html html, html

    html = '<img src="//foo.com/img/a.jpg" class="emoji" width="100" height="100">'
    assert_sanitize_html html, html
  end

  test "img src" do
    html = %(<img src="javascript:alert('')">)
    assert_sanitize_html "<img>", html
  end

  test "a" do
    html = '<a href="http://www.google.com" data-floor="100" target="_blank" rel="nofollow" class="btn btn-lg">111</a>'
    assert_sanitize_html html, html
  end
end
