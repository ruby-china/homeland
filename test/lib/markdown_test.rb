# frozen_string_literal: true

require "test_helper"

def assert_render_with_cases(cases)
  cases.each_key do |key|
    assert_markdown_render cases[key], key
  end
end

def assert_markdown_render(html, raw = nil)
  raw = yield if block_given?
  assert_html_equal html, Homeland::Markdown.call(raw)
end

def parse_markdown_doc(raw)
  Nokogiri::HTML.fragment(Homeland::Markdown.call(raw))
end

class Homeland::MarkdownTest < ActiveSupport::TestCase
  test "auto link right with Chinese neer URL" do
    cases = {
      "此版本并非线上的http://yavaeye.com 的源码.": '<p>此版本并非线上的<a href="http://yavaeye.com" rel="nofollow" target="_blank">http://yavaeye.com</a> 的源码.</p>',
      "http://foo.com,的???": '<p><a href="http://foo.com," rel="nofollow" target="_blank">http://foo.com,</a>的???</p>',
      "http://foo.com，的???": '<p><a href="http://foo.com" rel="nofollow" target="_blank">http://foo.com</a>，的???</p>',
      "http://foo.com。的???": '<p><a href="http://foo.com" rel="nofollow" target="_blank">http://foo.com</a>。的???</p>',
      "http://foo.com；的???": '<p><a href="http://foo.com" rel="nofollow" target="_blank">http://foo.com</a>；的???</p>'
    }

    assert_render_with_cases(cases)
  end

  test "auto link match complex urls" do
    cases = {
      "http://movie.douban.com/tag/%E7%BE%8E%E5%9B%BD": '<p><a href="http://movie.douban.com/tag/%E7%BE%8E%E5%9B%BD" rel="nofollow" target="_blank">http://movie.douban.com/tag/%E7%BE%8E%E5%9B%BD</a></p>',
      "http://ruby-china.org/self_posts/11?datas=20,33|100&format=.jpg": '<p><a href="http://ruby-china.org/self_posts/11?datas=20,33%7C100&amp;format=.jpg" rel="nofollow" target="_blank">http://ruby-china.org/self_posts/11?datas=20,33|100&amp;format=.jpg</a></p>'
    }

    assert_render_with_cases(cases)
  end

  test "bold text " do
    assert_markdown_render "<p><strong>bold</strong></p>", "**bold**"
  end

  test "italic text" do
    assert_markdown_render "<p><em>italic</em></p>", "*italic*"
  end

  test "strikethrough text" do
    assert_markdown_render "<p><del>strikethrough</del></p>", "~~strikethrough~~"
  end

  test "auto link" do
    assert_markdown_render '<p>this is a link: <a href="http://ruby-china.org" rel="nofollow" target="_blank">http://ruby-china.org</a> test</p>', "this is a link: http://ruby-china.org test"
    assert_markdown_render '<p><a href="http://ruby-china.org/~users" rel="nofollow" target="_blank">http://ruby-china.org/~users</a></p>', "http://ruby-china.org/~users"
    assert_markdown_render "<p>靠着中文<a href=\"http://foo.com\" rel=\"nofollow\" target=\"_blank\">http://foo.com</a>，</p>", "靠着中文http://foo.com，"
  end

  test "link mentioned user" do
    user = create(:user)

    html = <<~HTML
      <p>hello <a href="/#{user.name}" class="user-mention" title="@#{user.name}"><i>@</i>#{user.name}</a>
      <a href="/b" class="user-mention" title="@b"><i>@</i>b</a>
      <a href="/a" class="user-mention" title="@a"><i>@</i>a</a>
      <a href="/#{user.name}" class="user-mention" title="@#{user.name}"><i>@</i>#{user.name}</a>
      </p>
    HTML

    assert_markdown_render html, "hello @#{user.name} @b @a @#{user.name}"
  end

  test "link with nofollow" do
    cases = {
      "[Hello](http://hello.com)": %(<p><a href="http://hello.com" rel="nofollow" target="_blank" title="">Hello</a></p>),
      "[Hello](http://#{Setting.domain}/foo/bar \"This is title\")": %(<p><a href="http://#{Setting.domain}/foo/bar" title="This is title">Hello</a></p>),
      "[Hello](/foo/bar)": %(<p><a href="/foo/bar" title="">Hello</a></p>)
    }

    assert_render_with_cases(cases)
  end

  test "work with invalid url" do
    assert_markdown_render %(<p><a href="#foobar" title="">Hello</a></p>), "[Hello](#foobar)"
  end

  test "work with complex invalid url" do
    url = "https://google.com/foo/bar.html?spm=5176.2020520101.0.0.FAnpY8#Foo中文的Anchor"
    html = <<~HTML
      <p>
        <a href="https://google.com/foo/bar.html?spm=5176.2020520101.0.0.FAnpY8#Foo%E4%B8%AD%E6%96%87%E7%9A%84Anchor" rel="nofollow" target="_blank" title="">Hello</a>
      </p>
    HTML

    assert_markdown_render html, "[Hello](#{url})"

    assert_markdown_render %(<p><a href="" title="">Hello</a></p>), "[Hello]()"
  end

  test "link mentioned user at first of line" do
    assert_markdown_render '<p><a href="/huacnlee" class="user-mention" title="@huacnlee"><i>@</i>huacnlee</a> hello <a href="/ruby_box" class="user-mention" title="@ruby_box"><i>@</i>ruby_box</a></p>', "@huacnlee hello @ruby_box"
  end

  test "support ul,ol" do
    assert_markdown_render "<ul><li>Ruby on Rails</li><li>Sinatra</li></ul>", "* Ruby on Rails\n* Sinatra"
    assert_markdown_render "<ol><li>Ruby on Rails</li><li>Sinatra</li></ol>", "1. Ruby on Rails\n2. Sinatra"
  end

  test "email neer Chinese chars can work" do
    # 次处要保留 在某些场景下面 email 后面紧接中文逗号会出现编码异常，而导致错误
    assert_markdown_render "<p>可以给我邮件 monster@gmail.com，</p>", "可以给我邮件 monster@gmail.com，"
  end

  test "link mentioned floor" do
    assert_markdown_render %(<p><a href="#reply3" class="at_floor" data-floor="3">#3 楼</a>很强大</p>), "#3楼很强大"
  end

  test "right encoding with #1楼 @ichord 刚刚发布，有点问题" do
    assert_markdown_render %(<p><a href="#reply1" class="at_floor" data-floor="1">#1 楼</a> <a href="/ichord" class="user-mention" title="@ichord"><i>@</i>ichord</a> 刚刚发布，有点问题</p>), "#1楼 @ichord 刚刚发布，有点问题"
  end

  test "wrap break line" do
    assert_markdown_render "<p>line 1\nline 2</p>", "line 1\nline 2"
  end

  test "support inline code" do
    assert_markdown_render "<p>This is <code>Ruby</code></p>", "This is `Ruby`"
    assert_markdown_render "<p>This is<code>Ruby</code></p>", "This is`Ruby`"
  end

  test "highlight code block" do
    html = <<~HTML
      <div class="highlight">
      <pre class="highlight ruby"><code><span class="k">class</span> <span class="nc">Hello</span>\n\n<span class="k">end</span></code></pre>
      </div>
    HTML

    assert_markdown_render html do
      "```ruby\nclass Hello\n\nend\n```"
    end

    html = <<~HTML
      <div class="highlight">
      <pre class="highlight plaintext"><code>Hello world
      </code></pre>
      </div>
    HTML

    assert_markdown_render html do
      "```foo\nHello world\n```"
    end

    html = <<~HTML
      <div class="highlight">
      <pre class="highlight objective_c"><code><span class="n">Hello</span><span class="n">world</span></code></pre>
      </div>
    HTML

    assert_markdown_render html do
      "```objc\nHello world\n```"
    end
  end

  test "be able to identigy Ruby or RUBY as ruby language" do
    %w[Ruby RUBY].each do |lang|
      assert_markdown_render %(<div class="highlight"><pre class="highlight ruby"><code><span class="k">class</span> <span class="nc">Hello</span>\n<span class="k">end</span>\n</code></pre></div>) do
        "```#{lang}\nclass Hello\nend\n```"
      end
    end
  end

  test "highlight code block after the content" do
    assert_markdown_render %(<p>this code:</p>\n<div class="highlight"><pre class="highlight plaintext"><code>gem install rails\n</code></pre></div>) do
      "this code:\n```\ngem install rails\n```\n"
    end
  end

  test "highlight code block without language" do
    assert_markdown_render %(<div class="highlight"><pre class="highlight plaintext"><code>gem install ruby\n</code></pre></div>) do
      "```\ngem install ruby\n```"
    end
  end

  test "strip code indent" do
    code = <<~CODE
      ```
            def foo
              puts "Hahah"
            end
      ```
    CODE

    expect_code = <<~CODE
      ```
      def foo
        puts "Hahah"
      end
      ```
    CODE

    assert_equal Homeland::Markdown.call(expect_code), Homeland::Markdown.call(code)
  end

  test "not filter underscore" do
    assert_markdown_render "<p>ruby_china_image <code>ruby_china_image</code></p>", "ruby_china_image `ruby_china_image`"
    assert_markdown_render %(<div class="highlight"><pre class="highlight plaintext"><code>ruby_china_image\n</code></pre></div>) do
      "```\nruby_china_image\n```"
    end
  end

  test "inline link in heading - h3 with inline link" do
    assert_markdown_render %(<h3 id="rails_panel"><a href="https://github.com/dejan/rails_panel" rel="nofollow" target="_blank" title="">rails_panel</a></h3>), "### [rails_panel](https://github.com/dejan/rails_panel)"
  end

  test "h1" do
    assert_markdown_render %(<h2 id="foo Bar 的">foo Bar 的</h2>), "# foo Bar 的"
  end

  test "h2" do
    assert_markdown_render %(<h2 id="这是什么">这是什么</h2>), "## 这是什么"
  end

  test "h3" do
    assert_markdown_render %(<h3 id="这是什么">这是什么</h3>), "### 这是什么"
  end

  test "h4" do
    assert_markdown_render %(<h4 id="这是什么">这是什么</h4>), "#### 这是什么"
  end

  test "h5" do
    assert_markdown_render %(<h5 id="这是什么">这是什么</h5>), "##### 这是什么"
  end

  test "h6" do
    assert_markdown_render %(<h6 id="这是什么">这是什么</h6>), "###### 这是什么"
  end

  test "encoding with Chinese chars" do
    assert_markdown_render %(<p><a href="#reply1" class="at_floor" data-floor="1">#1 楼</a> <a href="/ichord" class="user-mention" title="@ichord"><i>@</i>ichord</a> 刚刚发布，有点问题</p>) do
      "#1楼 @ichord 刚刚发布，有点问题"
    end
  end

  test "sup and sub" do
    assert_markdown_render %(<p>L<sup>A</sup>T<sub>E</sub>X 结构化的路径覆盖（C<sub>i</sub>(k)-覆盖）</p>), "L<sup>A</sup>T<sub>E</sub>X结构化的路径覆盖（C<sub>i</sub>(k)-覆盖）"
  end

  test "footnotes" do
    assert_markdown_render %(<p>some ^strikethrough^</p>), "some ^strikethrough^"
  end

  test "strikethrough" do
    assert_markdown_render %(<p>some <del>strikethrough</del> text</p>), "some ~~strikethrough~~ text"
  end

  test "image" do
    assert_markdown_render %(<p><img src="foo.jpg" title="" alt=""></p>), "![](foo.jpg)"
    assert_markdown_render %(<p><img src="foo.jpg" title="titlebb" alt="alt text"></p>), '![alt text](foo.jpg "titlebb")'
    assert_markdown_render %(<p><img src="foo.jpg" title="titlebb" alt="alt text"></p>), "![alt text](foo.jpg titlebb)"
    assert_markdown_render %(<p><img src="foo.jpg" width="200px" alt="alt text"></p>), "![alt text](foo.jpg =200x)"
    assert_markdown_render %(<p><img src="foo.jpg" height="200px" alt="alt text"></p>), "![alt text](foo.jpg =x200)"
    assert_markdown_render %(<p><img src="foo.jpg" width="100px" height="200px" alt="alt text"></p>), "![alt text](foo.jpg =100x200)"
  end

  test "strong" do
    assert_markdown_render %(<p>some <strong>strong</strong> text</p>), "some **strong** text"
  end

  test "mention" do
    cases = {
      "@foo": %(<p><a href="/foo" class="user-mention" title="@foo"><i>@</i>foo</a></p>),
      "@_underscore_": %(<p><a href="/_underscore_" class="user-mention" title="@_underscore_"><i>@</i>_underscore_</a></p>),
      "@foo.bar ss": %(<p><a href="/foo.bar" class="user-mention" title="@foo.bar"><i>@</i>foo.bar</a> ss</p>),
      "@__underscore__": %(<p><a href="/__underscore__" class="user-mention" title="@__underscore__"><i>@</i>__underscore__</a></p>),
      "@ruby-china": %(<p><a href="/ruby-china" class="user-mention" title="@ruby-china"><i>@</i>ruby-china</a></p>),
      "@small_fish__": %(<p><a href="/small_fish__" class="user-mention" title="@small_fish__"><i>@</i>small_fish__</a></p>),
      "`@small_fish__`": %(<p><code>@small_fish__</code></p>),
      "`@user`": %(<p><code>@user</code></p>)
    }

    assert_render_with_cases cases

    assert_markdown_render "<div class=\"highlight\"><pre class=\"highlight ruby\"><code><span class=\"vi\">@small_fish__</span><span class=\"o\">=</span><span class=\"mi\">100</span></code></pre></div>" do
      <<~MD
        ```ruby
        @small_fish__ = 100
        ```
      MD
    end

    assert_markdown_render "<div class=\"highlight\"><pre class=\"highlight plaintext\"><code>@user\n</code></pre></div>" do
      <<~MD
        ```
        @user
        ```
      MD
    end

    # @user in link
    assert_markdown_render "<p><a href=\"http://medium.com/@user/foo\" rel=\"nofollow\" target=\"_blank\">http://medium.com/@user/foo</a></p>", "http://medium.com/@user/foo"
  end

  test "mention floor #12f in text" do
    doc = parse_markdown_doc("#12f")
    assert_equal 1, doc.css("a").size
    assert_equal "#reply12", doc.css("a").first[:href]
    assert_equal "at_floor", doc.css("a").first[:class]
    assert_equal "12", doc.css("a").first["data-floor"]
    assert_equal "#12f", doc.css("a").first.inner_html
  end

  test "mention floor #12f in code" do
    doc = parse_markdown_doc("`#12f`")
    assert_equal true, doc.css("a").blank?
    assert_equal "#12f", doc.css("code").inner_html
  end

  test "mention floor #12f in block code" do
    raw = <<~MD
      ```
      #12f
      ```
    MD

    doc = parse_markdown_doc(raw)

    assert_equal true, doc.css("a").blank?
    assert_equal "#12f\n", doc.css("pre code").inner_html
  end

  test "emoji in text" do
    doc = parse_markdown_doc(":apple:")
    assert_equal 1, doc.css("img").size
    assert_equal "https://twemoji.ruby-china.com/2/svg/1f34e.svg", doc.css("img").first[:src]
    assert_equal "twemoji", doc.css("img").first[:class]
    assert_equal ":apple:", doc.css("img").first[:title]

    doc = parse_markdown_doc(":-1:")
    assert_equal ":-1:", doc.css("img").first[:title]

    doc = parse_markdown_doc(":arrow_lower_left:")
    assert_equal ":arrow_lower_left:", doc.css("img").first[:title]
  end

  test "emoji :apple: in code" do
    doc = parse_markdown_doc("`:apple:`")

    assert_equal true, doc.css("a").blank?
    assert_equal ":apple:", doc.css("code").inner_html
  end

  test "emoji :apple: in block code" do
    raw = <<~MD
      ```
      :apple:
      ```
    MD
    doc = parse_markdown_doc(raw)

    assert_equal true, doc.css("a").blank?
    assert_equal ":apple:\n", doc.css("pre code").inner_html
  end

  test "``` use with code" do
    raw = <<~MD
      ```
      class Foo; end
      ```
    MD
    doc = parse_markdown_doc(raw)
    assert_equal "highlight plaintext", doc.css("pre").attr("class").value
  end

  test "```ruby use with code" do
    raw = <<~MD
      ```ruby
      class Foo; end
      ```
    MD

    doc = parse_markdown_doc(raw)
    assert_equal "highlight ruby", doc.css("pre").attr("class").value
  end

  test 'indent in raw with \t' do
    raw = "\t\tclass Foo; end"
    doc = parse_markdown_doc(raw)
    assert_equal true, doc.css("pre").blank?
  end

  test "indent in raw with space" do
    raw = "    class Foo; end"
    doc = parse_markdown_doc(raw)
    assert_equal true, doc.css("pre").blank?
  end

  test "list" do
    assert_markdown_render %(<p>foo</p>\n\n<ul>\n<li>123</li>\n<li>456</li>\n</ul>), %(foo\n- 123\n- 456)
  end

  test "tables" do
    raw = <<~MD
      | header 1 | header 3 |
      | -------- | -------- |
      | cell 1   | cell 2   |
      | cell 3   | cell 4   |
    MD

    assert_markdown_render "<div class=\"table-responsive\"><table class=\"table table-bordered table-striped\">\n<tr>\n<th>header 1</th>\n<th>header 3</th>\n</tr>\n<tr>\n<td>cell 1</td>\n<td>cell 2</td>\n</tr>\n<tr>\n<td>cell 3</td>\n<td>cell 4</td>\n</tr>\n</table></div>", raw
  end

  test "embed" do
    assert_markdown_render "<p><span class=\"embed-responsive embed-responsive-16by9\"><iframe class=\"embed-responsive-item\" src=\"//www.youtube.com/embed/SccR4kqBvy8\" allowfullscreen></iframe></span></p>" do
      %(https://www.youtube.com/watch?v=SccR4kqBvy8)
    end

    assert_markdown_render %(<p><span class="embed-responsive embed-responsive-16by9"><iframe class="embed-responsive-item" src="https://player.vimeo.com/video/159449591" allowfullscreen></iframe></span></p>) do
      %(https://vimeo.com/159449591)
    end

    assert_markdown_render "<p><span class=\"embed-responsive embed-responsive-16by9\"><iframe class=\"embed-responsive-item\" src=\"//player.youku.com/embed/XMjUzMTk4NTk2MA==\" allowfullscreen></iframe></span></p>" do
      %(https://v.youku.com/v_show/id_XMjUzMTk4NTk2MA==.html?from=y1.3-idx-beta-1519-23042.223465.1-1&spm=a2hww.20023042.m_223465.5~5~5~5~5~5~A#paction)
    end

    assert_markdown_render "<p><span class=\"embed-responsive embed-responsive-16by9\"><iframe class=\"embed-responsive-item\" src=\"//player.bilibili.com/player.html?aid=86873549\" allowfullscreen></iframe></span></p>" do
      %(https://www.bilibili.com/video/av86873549)
    end

    assert_markdown_render "<p><span class=\"embed-responsive embed-responsive-16by9\"><iframe class=\"embed-responsive-item\" src=\"//player.bilibili.com/player.html?aid=86873549\" allowfullscreen></iframe></span></p>" do
      %(https://bilibili.com/video/av86873549)
    end
  end

  test "Escape HTML tags" do
    assert_markdown_render %(<p><img src="aaa.jpg" class="bb"> aaa</p>) do
      %(<img src="aaa.jpg" class="bb"> aaa)
    end

    assert_markdown_render "<script>aaa</script>" do
      "<script>aaa</script>"
    end

    assert_markdown_render '<p><a href="https://www.flickr.com/photos/123590011@N08/sets/72157644587013882/" rel="nofollow" target="_blank">https://www.flickr.com/photos/123590011@N08/sets/72157644587013882/</a></p>' do
      "https://www.flickr.com/photos/123590011@N08/sets/72157644587013882/"
    end
  end

  test "imageproxy" do
    raw = <<~MD
      ![](https://homeland.ruby-china.org/images/text-logo.svg)
      ![](http://localhost/foo/bar.jpg)
    MD

    expect = <<~HTML
      <p>
        <img src="https://homeland.ruby-china.org/images/text-logo.svg" title="" alt="">
        <img src="http://localhost/foo/bar.jpg" title="" alt="">
      </p>
    HTML

    assert_markdown_render expect, raw

    Setting.stub(:imageproxy_url, "https://imageproxy.ruby-china.com/1000x/") do
      expect = <<~HTML
        <p>
          <img src="https://imageproxy.ruby-china.com/1000x/https://homeland.ruby-china.org/images/text-logo.svg" title="" alt="">
          <img src="http://localhost/foo/bar.jpg" title="" alt="">
        </p>
      HTML

      assert_markdown_render expect, raw
    end
  end

  test "Full example" do
    raw = read_file("markdown/raw.md")
    out = read_file("markdown/out.html.txt")

    assert_markdown_render out, raw
  end
end
