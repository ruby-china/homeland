# frozen_string_literal: true

require "rails_helper"

def assert_render_with_cases(cases)
  cases.each_key do |key|
    assert_markdown_render cases[key], key
  end
end

def assert_markdown_render(html, raw = nil)
  raw = yield if block_given?
  assert_html_equal html, Homeland::Markdown.call(raw)
end

describe "markdown" do
  describe Homeland::Markdown do
    let(:raw) { "" }
    let!(:doc) { Nokogiri::HTML.fragment(Homeland::Markdown.call(raw)) }
    subject { doc }

    describe "general" do
      describe "markdown" do
        it "should right with Chinese neer URL" do
          cases = {
            "此版本并非线上的http://yavaeye.com 的源码.": '<p>此版本并非线上的<a href="http://yavaeye.com" rel="nofollow" target="_blank">http://yavaeye.com</a> 的源码.</p>',
            "http://foo.com,的???": '<p><a href="http://foo.com," rel="nofollow" target="_blank">http://foo.com,</a>的???</p>',
            "http://foo.com，的???": '<p><a href="http://foo.com" rel="nofollow" target="_blank">http://foo.com</a>，的???</p>',
            "http://foo.com。的???": '<p><a href="http://foo.com" rel="nofollow" target="_blank">http://foo.com</a>。的???</p>',
            "http://foo.com；的???": '<p><a href="http://foo.com" rel="nofollow" target="_blank">http://foo.com</a>；的???</p>',
          }

          assert_render_with_cases(cases)
        end

        it "should match complex urls" do
          cases = {
            "http://movie.douban.com/tag/%E7%BE%8E%E5%9B%BD": '<p><a href="http://movie.douban.com/tag/%E7%BE%8E%E5%9B%BD" rel="nofollow" target="_blank">http://movie.douban.com/tag/%E7%BE%8E%E5%9B%BD</a></p>',
            "http://ruby-china.org/self_posts/11?datas=20,33|100&format=.jpg": '<p><a href="http://ruby-china.org/self_posts/11?datas=20,33%7C100&amp;format=.jpg" rel="nofollow" target="_blank">http://ruby-china.org/self_posts/11?datas=20,33|100&amp;format=.jpg</a></p>'
          }

          assert_render_with_cases(cases)
        end

        it "should bold text " do
          assert_markdown_render "<p><strong>bold</strong></p>", "**bold**"
        end

        it "should italic text" do
          assert_markdown_render "<p><em>italic</em></p>", "*italic*"
        end

        it "should strikethrough text" do
          assert_markdown_render "<p><del>strikethrough</del></p>", "~~strikethrough~~"
        end

        it "should auto link" do
          assert_markdown_render '<p>this is a link: <a href="http://ruby-china.org" rel="nofollow" target="_blank">http://ruby-china.org</a> test</p>', "this is a link: http://ruby-china.org test"
        end

        it "should auto link" do
          assert_markdown_render '<p><a href="http://ruby-china.org/~users" rel="nofollow" target="_blank">http://ruby-china.org/~users</a></p>', "http://ruby-china.org/~users"
        end

        it "should auto link with Chinese" do
          assert_markdown_render "<p>靠着中文<a href=\"http://foo.com\" rel=\"nofollow\" target=\"_blank\">http://foo.com</a>，</p>", "靠着中文http://foo.com，"
        end

        it "should link mentioned user" do
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

        it "should link with nofollow" do
          cases = {
            "[Hello](http://hello.com)": %(<p><a href="http://hello.com" rel="nofollow" target="_blank" title="">Hello</a></p>),
            "[Hello](http://#{Setting.domain}/foo/bar \"This is title\")": %(<p><a href="http://#{Setting.domain}/foo/bar" title="This is title">Hello</a></p>),
            "[Hello](/foo/bar)": %(<p><a href="/foo/bar" title="">Hello</a></p>),
          }

          assert_render_with_cases(cases)
        end

        it "should work with invalid url" do
          assert_markdown_render %(<p><a href="#foobar" title="">Hello</a></p>), "[Hello](#foobar)"
        end

        it "should work with complex invalid url" do
          url = "https://google.com/foo/bar.html?spm=5176.2020520101.0.0.FAnpY8#Foo中文的Anchor"
          html = <<~HTML
            <p>
              <a href="https://google.com/foo/bar.html?spm=5176.2020520101.0.0.FAnpY8#Foo%E4%B8%AD%E6%96%87%E7%9A%84Anchor" rel="nofollow" target="_blank" title="">Hello</a>
            </p>
          HTML

          assert_markdown_render html, "[Hello](#{url})"

          assert_markdown_render %(<p><a href="" title="">Hello</a></p>), "[Hello]()"
        end

        it "should link mentioned user at first of line" do
          assert_markdown_render '<p><a href="/huacnlee" class="user-mention" title="@huacnlee"><i>@</i>huacnlee</a> hello <a href="/ruby_box" class="user-mention" title="@ruby_box"><i>@</i>ruby_box</a></p>', "@huacnlee hello @ruby_box"
        end

        it "should support ul,ol" do
          assert_markdown_render "<ul><li>Ruby on Rails</li><li>Sinatra</li></ul>", "* Ruby on Rails\n* Sinatra"
          assert_markdown_render "<ol><li>Ruby on Rails</li><li>Sinatra</li></ol>", "1. Ruby on Rails\n2. Sinatra"
        end

        it "should email neer Chinese chars can work" do
          # 次处要保留 在某些场景下面 email 后面紧接中文逗号会出现编码异常，而导致错误
          assert_markdown_render "<p>可以给我邮件 monster@gmail.com，</p>", "可以给我邮件 monster@gmail.com，"
        end

        it "should link mentioned floor" do
          assert_markdown_render %(<p><a href="#reply3" class="at_floor" data-floor="3">#3 楼</a>很强大</p>), "#3楼很强大"
        end

        it "should right encoding with #1楼 @ichord 刚刚发布，有点问题" do
          assert_markdown_render %(<p><a href="#reply1" class="at_floor" data-floor="1">#1 楼</a> <a href="/ichord" class="user-mention" title="@ichord"><i>@</i>ichord</a> 刚刚发布，有点问题</p>), "#1楼 @ichord 刚刚发布，有点问题"
        end

        it "should wrap break line" do
          assert_markdown_render "<p>line 1\nline 2</p>", "line 1\nline 2"
        end

        it "should support inline code" do
          assert_markdown_render "<p>This is <code>Ruby</code></p>", "This is `Ruby`"
          assert_markdown_render "<p>This is<code>Ruby</code></p>", "This is`Ruby`"
        end

        it "should highlight code block" do
          html = <<~HTML
          <div class="highlight">
          <pre class="highlight ruby"><code><span class="k">class</span> <span class="nc">Hello</span>\n\n<span class="k">end</span></code></pre>
          </div>
          HTML

          assert_markdown_render html do
            "```ruby\nclass Hello\n\nend\n```"
          end
        end

        it "should be able to identigy Ruby or RUBY as ruby language" do
          %w[Ruby RUBY].each do |lang|
            assert_markdown_render %(<div class="highlight"><pre class="highlight ruby"><code><span class="k">class</span> <span class="nc">Hello</span>\n<span class="k">end</span>\n</code></pre></div>) do
              "```#{lang}\nclass Hello\nend\n```"
            end
          end
        end

        it "should highlight code block after the content" do
          assert_markdown_render %(<p>this code:</p>\n<div class="highlight"><pre class="highlight plaintext"><code>gem install rails\n</code></pre></div>) do
            "this code:\n```\ngem install rails\n```\n"
          end
        end

        it "should highlight code block without language" do
          assert_markdown_render %(<div class="highlight"><pre class="highlight plaintext"><code>gem install ruby\n</code></pre></div>) do
            "```\ngem install ruby\n```"
          end
        end

        it "should strip code indent" do
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

        it "should not filter underscore" do
          assert_markdown_render "<p>ruby_china_image <code>ruby_china_image</code></p>", "ruby_china_image `ruby_china_image`"
          assert_markdown_render %(<div class="highlight"><pre class="highlight plaintext"><code>ruby_china_image\n</code></pre></div>) do
            "```\nruby_china_image\n```"
          end
        end
      end
    end

    describe "inline link in heading" do
      subject { super().inner_html }

      context "h3 with inline link" do
        let(:raw) { "### [rails_panel](https://github.com/dejan/rails_panel)" }
        let(:html) { %(<h3 id="rails_panel"><a href="https://github.com/dejan/rails_panel" rel="nofollow" target="_blank" title="">rails_panel</a></h3>) }
        it { is_expected.to eq(html) }
      end
    end

    describe "heading" do
      subject { super().inner_html }

      context "h1" do
        let(:raw) { "# foo Bar 的" }
        it { is_expected.to eq(%(<h2 id="foo Bar 的">foo Bar 的</h2>)) }
      end

      context "h2" do
        let(:raw) { "## 这是什么" }
        it { is_expected.to eq(%(<h2 id="这是什么">这是什么</h2>)) }
      end

      context "h3" do
        let(:raw) { "### 这是什么" }
        it { is_expected.to eq(%(<h3 id="这是什么">这是什么</h3>)) }
      end

      context "h4" do
        let(:raw) { "#### 这是什么" }
        it { is_expected.to eq(%(<h4 id="这是什么">这是什么</h4>)) }
      end

      context "h5" do
        let(:raw) { "##### 这是什么" }
        it { is_expected.to eq(%(<h5 id="这是什么">这是什么</h5>)) }
      end

      context "h6" do
        let(:raw) { "###### 这是什么" }
        it { is_expected.to eq(%(<h6 id="这是什么">这是什么</h6>)) }
      end
    end

    describe "encoding with Chinese chars" do
      context "a simple" do
        let(:raw) { "#1楼 @ichord 刚刚发布，有点问题" }

        describe "#inner_html" do
          subject { super().inner_html }
          it { is_expected.to eq(%(<p><a href="#reply1" class="at_floor" data-floor="1">#1 楼</a> <a href="/ichord" class="user-mention" title="@ichord"><i>@</i>ichord</a> 刚刚发布，有点问题</p>)) }
        end
      end
    end

    describe "footnotes" do
      let(:raw) { "some ^strikethrough^" }

      describe "#inner_html" do
        subject { super().inner_html }
        it { is_expected.to eq(%(<p>some ^strikethrough^</p>)) }
      end
    end

    describe "strikethrough" do
      let(:raw) { "some ~~strikethrough~~ text" }

      describe "#inner_html" do
        subject { super().inner_html }
        it { is_expected.to eq(%(<p>some <del>strikethrough</del> text</p>)) }
      end
    end

    describe "image" do
      subject { super().inner_html }

      context "simple image" do
        let(:raw) { "![](foo.jpg)" }

        it { is_expected.to eq(%(<p><img src="foo.jpg" title="" alt=""></p>)) }
      end

      context "image with a title" do
        let(:raw) { '![alt text](foo.jpg "titlebb")' }

        it { is_expected.to eq(%(<p><img src="foo.jpg" title="titlebb" alt="alt text"></p>)) }
      end

      context "image with a title without quote" do
        let(:raw) { "![alt text](foo.jpg titlebb)" }

        it { is_expected.to eq(%(<p><img src="foo.jpg" title="titlebb" alt="alt text"></p>)) }
      end

      context "image has width" do
        let(:raw) { "![alt text](foo.jpg =200x)" }

        it { is_expected.to eq(%(<p><img src="foo.jpg" width="200px" alt="alt text"></p>)) }
      end

      context "image has height" do
        let(:raw) { "![alt text](foo.jpg =x200)" }

        it { is_expected.to eq(%(<p><img src="foo.jpg" height="200px" alt="alt text"></p>)) }
      end

      context "image has width and height" do
        let(:raw) { "![alt text](foo.jpg =100x200)" }

        it { is_expected.to eq(%(<p><img src="foo.jpg" width="100px" height="200px" alt="alt text"></p>)) }
      end
    end

    describe "strong" do
      let(:raw) { "some **strong** text" }

      describe "#inner_html" do
        subject { super().inner_html }
        it { is_expected.to eq(%(<p>some <strong>strong</strong> text</p>)) }
      end
    end

    describe "at user" do
      context "@user in text" do
        let(:raw) { "@foo" }

        it "has a link" do
          assert_equal 1, doc.css("a").size
          assert_equal %(<p><a href="/foo" class="user-mention" title="@foo"><i>@</i>foo</a></p>), doc.inner_html
        end
      end

      context "@_underscore_ in text" do
        let(:raw) { "@_underscore_" }

        specify { assert_equal %(<p><a href="/_underscore_" class="user-mention" title="@_underscore_"><i>@</i>_underscore_</a></p>), doc.inner_html }
      end

      context "@foo.bar in text" do
        let(:raw) { "@foo.bar ss" }

        specify { assert_equal %(<p><a href="/foo.bar" class="user-mention" title="@foo.bar"><i>@</i>foo.bar</a> ss</p>), doc.inner_html }
      end

      context "@__underscore__ in text" do
        let(:raw) { "@__underscore__" }

        specify { assert_equal %(<p><a href="/__underscore__" class="user-mention" title="@__underscore__"><i>@</i>__underscore__</a></p>), doc.inner_html }
      end

      context "@ruby-china in text" do
        let(:raw) { "@ruby-china" }
        specify { assert_equal %(<p><a href="/ruby-china" class="user-mention" title="@ruby-china"><i>@</i>ruby-china</a></p>), doc.inner_html }
      end

      context "@small_fish__ in text" do
        let(:raw) { "@small_fish__" }
        specify { assert_equal %(<p><a href="/small_fish__" class="user-mention" title="@small_fish__"><i>@</i>small_fish__</a></p>), doc.inner_html }
      end

      context "@small_fish__ in code block" do
        let(:raw) { "`@small_fish__`" }
        specify { assert_equal "@small_fish__", doc.css("code").first.inner_html }
      end

      context "@small_fish__ in ruby code block" do
        let(:raw) do
          <<~MD
            ```ruby
            @small_fish__ = 100
            ```
          MD
        end

        specify { assert_equal "@small_fish__", doc.search("pre code").children[0].inner_html }
      end

      context "@user in code" do
        let(:raw) { "`@user`" }

        specify { assert_equal true, doc.css("a").blank? }
        specify { assert_equal "@user", doc.css("code").inner_html }
      end

      context "@user in block code" do
        let(:raw) do
          <<~MD
            ```
            @user
            ```
          MD
        end

        specify { assert_equal true, doc.css("a").blank? }
        specify { assert_equal "@user\n", doc.css("pre code").inner_text }
      end

      context "@var in coffeescript" do
        let(:raw) do
          <<~MD
            ```coffeescript
            @var
            ```
          MD
        end

        it "should not leave it as placeholder" do
          assert_includes doc.to_html, "var"
        end
      end

      context "=@var in sql" do
        let(:raw) do
          <<~MD
            ```sql
            select (@x:=@var+1) as i
            ```
          MD
        end

        it "should not leave it as placeholder" do
          assert_includes doc.to_html, "var"
        end
      end

      context "@user in link" do
        let(:raw) { "http://medium.com/@user/foo" }
        specify { assert_equal true, doc.css(".user-mention").blank? }
      end
    end

    # }}}

    # {{{ describe mention floor

    describe "mention floor" do
      context " #12f in text" do
        let(:raw) { "#12f" }

        it "has a link" do
          assert_equal 1, doc.css("a").size
        end

        describe "the link" do
          subject { doc.css("a").first }

          describe "[:href]" do
            subject { super()[:href] }
            it { is_expected.to eq("#reply12") }
          end

          describe "[:class]" do
            subject { super()[:class] }
            it { is_expected.to eq("at_floor") }
          end

          describe "['data-floor']" do
            subject { super()["data-floor"] }
            it { is_expected.to eq("12") }
          end

          describe "#inner_html" do
            subject { super().inner_html }
            it { is_expected.to eq("#12f") }
          end
        end
      end

      context " #12f in code" do
        let(:raw) { "`#12f`" }

        specify { assert_equal true, doc.css("a").blank? }
        specify { assert_equal "#12f", doc.css("code").inner_html }
      end

      context " #12f in block code" do
        let(:raw) do
          <<~MD
            ```
            #12f
            ```
          MD
        end

        specify { assert_equal true, doc.css("a").blank? }
        specify { assert_equal "#12f\n", doc.css("pre code").inner_html }
      end
    end

    # }}}

    # {{{ describe 'emoji'

    describe "emoji" do
      context ":apple: in text" do
        let(:raw) { ":apple:" }

        it "has a image" do
          assert_equal 1, doc.css("img").size
        end

        describe "the image" do
          subject { doc.css("img").first }

          describe "[:src]" do
            subject { super()[:src] }
            it { is_expected.to eq("https://twemoji.ruby-china.com/2/svg/1f34e.svg") }
          end

          describe "[:class]" do
            subject { super()[:class] }
            it { is_expected.to eq("twemoji") }
          end

          describe "[:title]" do
            subject { super()[:title] }
            it { is_expected.to eq(":apple:") }
          end
        end
      end

      context ":-1:" do
        let(:raw) { ":-1:" }
        specify { assert_equal ":-1:", doc.css("img").first[:title] }
      end
      context ":arrow_lower_left:" do
        let(:raw) { ":arrow_lower_left:" }
        specify { assert_equal ":arrow_lower_left:", doc.css("img").first[:title] }
      end

      context ":apple: in code" do
        let(:raw) { "`:apple:`" }

        specify { assert_equal true, doc.css("a").blank? }
        specify { assert_equal ":apple:", doc.css("code").inner_html }
      end

      context ":apple: in block code" do
        let(:raw) do
          <<~MD
            ```
            :apple:
            ```
          MD
        end

        specify { assert_equal true, doc.css("a").blank? }
        specify { assert_equal ":apple:\n", doc.css("pre code").inner_html }
      end
    end

    # }}}

    describe "The code" do
      context "``` use with code" do
        let(:raw) do
          %(```
          class Foo; end
          ```)
        end

        specify { assert_equal "highlight plaintext", doc.css("pre").attr("class").value }
      end

      context "```ruby use with code" do
        let(:raw) do
          %(```ruby
          class Foo; end
          ```)
        end

        specify { assert_equal "highlight ruby", doc.css("pre").attr("class").value }
      end

      context 'indent in raw with \t' do
        let(:raw) { "\t\tclass Foo; end" }

        specify { assert_equal true, doc.css("pre").blank? }
      end

      context "indent in raw with space" do
        let(:raw) { "    class Foo; end" }

        specify { assert_equal true, doc.css("pre").blank? }
      end
    end

    describe "list" do
      let(:raw) do
        %(foo\n- 123\n- 456)
      end

      it do
        assert_equal %(<p>foo</p>\n\n<ul>\n<li>123</li>\n<li>456</li>\n</ul>), doc.inner_html
      end
    end

    describe "tables" do
      let(:raw) do
        <<~MD
          | header 1 | header 3 |
          | -------- | -------- |
          | cell 1   | cell 2   |
          | cell 3   | cell 4   |
        MD
      end

      it { assert_equal "<div class=\"table-responsive\"><table class=\"table table-bordered table-striped\">\n<tr>\n<th>header 1</th>\n<th>header 3</th>\n</tr>\n<tr>\n<td>cell 1</td>\n<td>cell 2</td>\n</tr>\n<tr>\n<td>cell 3</td>\n<td>cell 4</td>\n</tr>\n</table></div>", doc.inner_html}
    end

    describe "embed" do
      describe "Youtube" do
        let(:raw) do
          %(https://www.youtube.com/watch?v=SccR4kqBvy8)
        end

        it { assert_equal "<p><span class=\"embed-responsive embed-responsive-16by9\"><iframe class=\"embed-responsive-item\" src=\"//www.youtube.com/embed/SccR4kqBvy8\" allowfullscreen></iframe></span></p>", doc.inner_html}
      end

      describe "Vimeo" do
        let(:raw) do
          %(https://vimeo.com/159449591)
        end

        it { assert_equal %(<p><span class="embed-responsive embed-responsive-16by9"><iframe class="embed-responsive-item" src="https://player.vimeo.com/video/159449591" allowfullscreen></iframe></span></p>), doc.inner_html }
      end

      describe "Youku" do
        let(:raw) do
          %(http://v.youku.com/v_show/id_XMjUzMTk4NTk2MA==.html?from=y1.3-idx-beta-1519-23042.223465.1-1&spm=a2hww.20023042.m_223465.5~5~5~5~5~5~A#paction)
        end

        it { assert_equal "<p><span class=\"embed-responsive embed-responsive-16by9\"><iframe class=\"embed-responsive-item\" src=\"//player.youku.com/embed/XMjUzMTk4NTk2MA==\" allowfullscreen></iframe></span></p>", doc.inner_html }
      end
    end

    describe "Escape HTML tags" do
      context "<img> tag" do
        let(:raw) { %(<img src="aaa.jpg" class="bb" /> aaa) }

        describe "#inner_html" do
          subject { super().inner_html }
          it { is_expected.to eq(%(<p><img src="aaa.jpg" class="bb"> aaa</p>)) }
        end
      end

      context "<script> tag" do
        let(:raw) { "<script>aaa</script>" }

        describe "#inner_html" do
          subject { super().inner_html }
          it { is_expected.to eq("<script>aaa</script>") }
        end
      end

      context "<a> tag" do
        let(:raw) { "https://www.flickr.com/photos/123590011@N08/sets/72157644587013882/" }

        subject { super().inner_html }
        it "auto link with @ issue #322" do
          assert_equal '<p><a href="https://www.flickr.com/photos/123590011@N08/sets/72157644587013882/" rel="nofollow" target="_blank">https://www.flickr.com/photos/123590011@N08/sets/72157644587013882/</a></p>', subject
        end
      end
    end

    describe "Full example" do
      let(:raw) { File.open(Rails.root.join("spec/fixtures/markdown/raw.md")).read }
      let(:out) { File.open(Rails.root.join("spec/fixtures/markdown/out.html.txt")).read }

      it "should work" do
        assert_equal out.strip, doc.inner_html
      end
    end
  end
end
