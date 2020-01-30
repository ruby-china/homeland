# frozen_string_literal: true

require "rails_helper"

describe ApplicationHelper, type: :helper do
  describe ".sanitize_markdown" do
    describe "<a href>" do
      it "should work relative link" do
        html = '<a href="/foo">foo</a>'
        assert_equal html, helper.sanitize_markdown(html)
      end

      it "should work url link" do
        html = '<a href="http://foobar.com/foo">foo</a>'
        assert_equal html, helper.sanitize_markdown(html)
      end

      it "should block javascript" do
        assert_equal "<a>link</a>", helper.sanitize_markdown('<a href="javascript:alert()">link</a>')
      end
    end

    describe "<script>" do
      it "should block script" do
        assert_equal "foo", helper.sanitize_markdown("<script>alert("");</script>foo")
      end
    end

    describe "<style>" do
      it "should block style" do
        assert_equal "foo", helper.sanitize_markdown("<style>.body{}</style>foo")
      end
    end

    describe "<iframe>" do
      it "should block iframe" do
        assert_equal "", helper.sanitize_markdown('<iframe src="https://foobar.com"></iframe>')
      end

      it "should allow youtube iframe" do
        html = '<span class="embed-responsive embed-responsive-16by9">
        <iframe width="560" height="315" src="https://www.youtube.com/embed/gFQpxAKx_ds" class="embed" frameborder="0" allowfullscreen=""></iframe>
        </span>'
        assert_equal html, helper.sanitize_markdown(html)

        html = '<span class="embed-responsive embed-responsive-16by9">
        <iframe width="560" height="315" src="https://player.vimeo.com/video/159449591" class="embed" frameborder="0" allowfullscreen=""></iframe>
        </span>'
        assert_equal html, helper.sanitize_markdown(html)

        html = '<span class="embed-responsive embed-responsive-16by9">
        <iframe width="560" height="315" src="http://www.youtube.com/embed/gFQpxAKx_ds" class="embed" frameborder="0" allowfullscreen=""></iframe>
        </span>'
        assert_equal html, helper.sanitize_markdown(html)

        html = '<span class="embed-responsive embed-responsive-16by9">
        <iframe width="560" height="315" src="//www.youtube.com/embed/gFQpxAKx_ds" class="embed" frameborder="0" allowfullscreen=""></iframe>
        </span>'
        assert_equal html, helper.sanitize_markdown(html)

        html = '<iframe width="560" height="315" src="//www.youtube.com/aaa" class="embed" frameborder="0" allowfullscreen=""></iframe>'
        assert_equal "", helper.sanitize_markdown(html)
      end

      it "should allow youku iframe" do
        html = '<span class="embed-responsive embed-responsive-16by9">
        <iframe width="560" height="315" src="https://player.youku.com/embed/XMjUzMTk4NTk2MA==" class="embed" frameborder="0" allowfullscreen=""></iframe>
        </span>'
        assert_equal html, helper.sanitize_markdown(html)

        html = '<span class="embed-responsive embed-responsive-16by9">
        <iframe width="560" height="315" src="http://player.youku.com/embed/XMjUzMTk4NTk2MA==" class="embed" frameborder="0" allowfullscreen=""></iframe>
        </span>'
        assert_equal html, helper.sanitize_markdown(html)

        html = '<span class="embed-responsive embed-responsive-16by9">
        <iframe width="560" height="315" src="//player.youku.com/embed/XMjUzMTk4NTk2MA==" class="embed" frameborder="0" allowfullscreen=""></iframe>
        </span>'
        assert_equal html, helper.sanitize_markdown(html)

        html = '<iframe width="560" height="315" src="//player.youku.com/XMjUzMTk4NTk2MA==" class="embed" frameborder="0" allowfullscreen=""></iframe>'
        assert_equal "", helper.sanitize_markdown(html)

        html = '<iframe width="560" height="315" src="//www.youku.com/XMjUzMTk4NTk2MA==" class="embed" frameborder="0" allowfullscreen=""></iframe>'
        assert_equal "", helper.sanitize_markdown(html)
      end
    end

    describe "img" do
      it "should filter bad" do
        html = '<img src="javascript:alert" class="emoji" width="100" height="100">'
        assert_equal '<img class="emoji" width="100" height="100">', helper.sanitize_markdown(html)
      end

      it "should work" do
        html = '<img src="/img/a.jpg" class="emoji" width="100" height="100">'
        assert_equal html, helper.sanitize_markdown(html)

        html = '<img src="http://foo.com/img/a.jpg" class="emoji" width="100" height="100">'
        assert_equal html, helper.sanitize_markdown(html)

        html = '<img src="https://foo.com/img/a.jpg" class="emoji" width="100" height="100">'
        assert_equal html, helper.sanitize_markdown(html)

        html = '<img src="//foo.com/img/a.jpg" class="emoji" width="100" height="100">'
        assert_equal html, helper.sanitize_markdown(html)
      end

      it "should filter src" do
        html = '<img src="javascript:alert('')">'
        assert_equal "<img>", helper.sanitize_markdown(html)
      end
    end

    describe "a" do
      it "should work" do
        html = '<a href="http://www.google.com" data-floor="100" target="_blank" rel="nofollow" class="btn btn-lg">111</a>'
        assert_equal html, helper.sanitize_markdown(html)
      end
    end
  end
end
