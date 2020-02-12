# frozen_string_literal: true

require "spec_helper"

class SanitizeHelperTest < ActionView::TestCase
  include ApplicationHelper

  test "work relative link" do
    html = '<a href="/foo">foo</a>'
    assert_equal html, sanitize_markdown(html)
  end

  test "work url link" do
    html = '<a href="http://foobar.com/foo">foo</a>'
    assert_equal html, sanitize_markdown(html)
  end

  test "block javascript" do
    assert_equal "<a>link</a>", sanitize_markdown('<a href="javascript:alert()">link</a>')
  end

  test "block script" do
    assert_equal "foo", sanitize_markdown("<script>alert("");</script>foo")
  end

  test "block style" do
    assert_equal "foo", sanitize_markdown("<style>.body{}</style>foo")
  end

  test "block iframe" do
    assert_equal "", sanitize_markdown('<iframe src="https://foobar.com"></iframe>')
  end

  test "allow youtube iframe" do
    html = '<span class="embed-responsive embed-responsive-16by9">
    <iframe width="560" height="315" src="https://www.youtube.com/embed/gFQpxAKx_ds" class="embed" frameborder="0" allowfullscreen=""></iframe>
    </span>'
    assert_equal html, sanitize_markdown(html)

    html = '<span class="embed-responsive embed-responsive-16by9">
    <iframe width="560" height="315" src="https://player.vimeo.com/video/159449591" class="embed" frameborder="0" allowfullscreen=""></iframe>
    </span>'
    assert_equal html, sanitize_markdown(html)

    html = '<span class="embed-responsive embed-responsive-16by9">
    <iframe width="560" height="315" src="http://www.youtube.com/embed/gFQpxAKx_ds" class="embed" frameborder="0" allowfullscreen=""></iframe>
    </span>'
    assert_equal html, sanitize_markdown(html)

    html = '<span class="embed-responsive embed-responsive-16by9">
    <iframe width="560" height="315" src="//www.youtube.com/embed/gFQpxAKx_ds" class="embed" frameborder="0" allowfullscreen=""></iframe>
    </span>'
    assert_equal html, sanitize_markdown(html)

    html = '<iframe width="560" height="315" src="//www.youtube.com/aaa" class="embed" frameborder="0" allowfullscreen=""></iframe>'
    assert_equal "", sanitize_markdown(html)
  end

  test "allow youku iframe" do
    html = '<span class="embed-responsive embed-responsive-16by9">
    <iframe width="560" height="315" src="https://player.youku.com/embed/XMjUzMTk4NTk2MA==" class="embed" frameborder="0" allowfullscreen=""></iframe>
    </span>'
    assert_equal html, sanitize_markdown(html)

    html = '<span class="embed-responsive embed-responsive-16by9">
    <iframe width="560" height="315" src="http://player.youku.com/embed/XMjUzMTk4NTk2MA==" class="embed" frameborder="0" allowfullscreen=""></iframe>
    </span>'
    assert_equal html, sanitize_markdown(html)

    html = '<span class="embed-responsive embed-responsive-16by9">
    <iframe width="560" height="315" src="//player.youku.com/embed/XMjUzMTk4NTk2MA==" class="embed" frameborder="0" allowfullscreen=""></iframe>
    </span>'
    assert_equal html, sanitize_markdown(html)

    html = '<iframe width="560" height="315" src="//player.youku.com/XMjUzMTk4NTk2MA==" class="embed" frameborder="0" allowfullscreen=""></iframe>'
    assert_equal "", sanitize_markdown(html)

    html = '<iframe width="560" height="315" src="//www.youku.com/XMjUzMTk4NTk2MA==" class="embed" frameborder="0" allowfullscreen=""></iframe>'
    assert_equal "", sanitize_markdown(html)

    html = '<span class="embed-responsive embed-responsive-16by9">
    <iframe width="560" height="315" src="//player.bilibili.com/player.html?aid=86873549" class="embed" frameborder="0" allowfullscreen=""></iframe>
    </span>'
    assert_equal html, sanitize_markdown(html)
  end

  test "img filter bad" do
    html = '<img src="javascript:alert" class="emoji" width="100" height="100">'
    assert_equal '<img class="emoji" width="100" height="100">', sanitize_markdown(html)
  end

  test "img attrbutes" do
    html = '<img src="/img/a.jpg" class="emoji" width="100" height="100">'
    assert_equal html, sanitize_markdown(html)

    html = '<img src="http://foo.com/img/a.jpg" class="emoji" width="100" height="100">'
    assert_equal html, sanitize_markdown(html)

    html = '<img src="https://foo.com/img/a.jpg" class="emoji" width="100" height="100">'
    assert_equal html, sanitize_markdown(html)

    html = '<img src="//foo.com/img/a.jpg" class="emoji" width="100" height="100">'
    assert_equal html, sanitize_markdown(html)
  end

  test "img src" do
    html = '<img src="javascript:alert('')">'
    assert_equal "<img>", sanitize_markdown(html)
  end

  test "a" do
    html = '<a href="http://www.google.com" data-floor="100" target="_blank" rel="nofollow" class="btn btn-lg">111</a>'
    assert_equal html, sanitize_markdown(html)
  end
end
