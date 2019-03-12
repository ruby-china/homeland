# frozen_string_literal: true

require "rails_helper"

describe "markdown" do
  describe Homeland::Markdown do
    let(:raw) { "" }
    let!(:doc) { Nokogiri::HTML.fragment(Homeland::Markdown.call(raw)) }
    subject { doc }

    describe "general" do
      describe "markdown" do
        it "should right with Chinese neer URL" do
          # TODO: 这行是由于 Redcarpet 的 auto_link 方法转换连起来的会有编码错误
          #  @huacnlee提醒说在某些环境下面，下面测试会Pass。所以有可能在你的测试环境会失败。
          expect(Homeland::Markdown.call("此版本并非线上的http://yavaeye.com 的源码.")).to eq(
            '<p>此版本并非线上的<a href="http://yavaeye.com" rel="nofollow" target="_blank">http://yavaeye.com</a> 的源码.</p>'
          )
          expect(Homeland::Markdown.call("http://foo.com,的???")).to eq(
            '<p><a href="http://foo.com," rel="nofollow" target="_blank">http://foo.com,</a>的???</p>'
          )
          expect(Homeland::Markdown.call("http://foo.com，的???")).to eq(
            '<p><a href="http://foo.com" rel="nofollow" target="_blank">http://foo.com</a>，的???</p>'
          )
          expect(Homeland::Markdown.call("http://foo.com。的???")).to eq(
            '<p><a href="http://foo.com" rel="nofollow" target="_blank">http://foo.com</a>。的???</p>'
          )
          expect(Homeland::Markdown.call("http://foo.com；的???")).to eq(
            '<p><a href="http://foo.com" rel="nofollow" target="_blank">http://foo.com</a>；的???</p>'
          )
        end

        it "should match complex urls" do
          expect(Homeland::Markdown.call("http://movie.douban.com/tag/%E7%BE%8E%E5%9B%BD")).to eq(
            '<p><a href="http://movie.douban.com/tag/%E7%BE%8E%E5%9B%BD" rel="nofollow" target="_blank">http://movie.douban.com/tag/%E7%BE%8E%E5%9B%BD</a></p>'
          )
          expect(Homeland::Markdown.call("http://ruby-china.org/self_posts/11?datas=20,33|100&format=.jpg")).to eq(
            '<p><a href="http://ruby-china.org/self_posts/11?datas=20,33%7C100&amp;format=.jpg" rel="nofollow" target="_blank">http://ruby-china.org/self_posts/11?datas=20,33|100&amp;format=.jpg</a></p>'
          )
          expect(Homeland::Markdown.call("https://g.l/b/?fromgroups#!searchin/gitlabhq/self$20regist/gitlabhq/5ha_FyX-Pr4/VNZTPnSN0S4J")).to eq(
            '<p><a href="https://g.l/b/?fromgroups#!searchin/gitlabhq/self%2420regist/gitlabhq/5ha_FyX-Pr4/VNZTPnSN0S4J" rel="nofollow" target="_blank">https://g.l/b/?fromgroups#!searchin/gitlabhq/self$20regist/gitlabhq/5ha_FyX-Pr4/VNZTPnSN0S4J</a></p>'
          )
        end

        it "should bold text " do
          expect(Homeland::Markdown.call("**bold**")).to eq("<p><strong>bold</strong></p>")
        end

        it "should italic text" do
          expect(Homeland::Markdown.call("*italic*")).to eq("<p><em>italic</em></p>")
        end

        it "should strikethrough text" do
          expect(Homeland::Markdown.call("~~strikethrough~~")).to eq("<p><del>strikethrough</del></p>")
        end

        it "should auto link" do
          expect(Homeland::Markdown.call("this is a link: http://ruby-china.org test")).to eq(
            '<p>this is a link: <a href="http://ruby-china.org" rel="nofollow" target="_blank">http://ruby-china.org</a> test</p>'
          )
        end

        it "should auto link" do
          expect(Homeland::Markdown.call("http://ruby-china.org/~users")).to eq(
            '<p><a href="http://ruby-china.org/~users" rel="nofollow" target="_blank">http://ruby-china.org/~users</a></p>'
          )
        end

        it "should auto link with Chinese" do
          expect(Homeland::Markdown.call("靠着中文http://foo.com，")).to eq(
            "<p>靠着中文<a href=\"http://foo.com\" rel=\"nofollow\" target=\"_blank\">http://foo.com</a>，</p>"
          )
        end

        it "should link mentioned user" do
          user = create(:user)
          expect(Homeland::Markdown.call("hello @#{user.name} @b @a @#{user.name}")).to eq(
            "<p>hello <a href=\"/#{user.name}\" class=\"user-mention\" title=\"@#{user.name}\"><i>@</i>#{user.name}</a> <a href=\"/b\" class=\"user-mention\" title=\"@b\"><i>@</i>b</a> <a href=\"/a\" class=\"user-mention\" title=\"@a\"><i>@</i>a</a> <a href=\"/#{user.name}\" class=\"user-mention\" title=\"@#{user.name}\"><i>@</i>#{user.name}</a></p>"
          )
        end

        it "should link with nofollow" do
          expect(Homeland::Markdown.call("[Hello](http://hello.com)")).to eq(
            %(<p><a href="http://hello.com" rel="nofollow" target="_blank" title="">Hello</a></p>)
          )

          expect(Homeland::Markdown.call("[Hello](http://#{Setting.domain}/foo/bar \"This is title\")")).to eq(
            %(<p><a href="http://#{Setting.domain}/foo/bar" title="This is title">Hello</a></p>)
          )

          expect(Homeland::Markdown.call("[Hello](/foo/bar)")).to eq(
            %(<p><a href="/foo/bar" title="">Hello</a></p>)
          )
        end

        it "should work with invalid url" do
          expect(Homeland::Markdown.call(%([Hello](#foobar)))).to eq(
            %(<p><a href="#foobar" title="">Hello</a></p>)
          )
        end

        it "should work with complex invalid url" do
          url = "https://google.com/foo/bar.html?spm=5176.2020520101.0.0.FAnpY8#Foo中文的Anchor"
          expect(Homeland::Markdown.call(%([Hello](#{url})))).to eq(
            %(<p><a href="https://google.com/foo/bar.html?spm=5176.2020520101.0.0.FAnpY8#Foo%E4%B8%AD%E6%96%87%E7%9A%84Anchor" rel="nofollow" target="_blank" title="">Hello</a></p>)
          )

          expect(Homeland::Markdown.call(%([Hello]()))).to eq(
            %(<p><a href="" title="">Hello</a></p>)
          )
        end

        it "should link mentioned user at first of line" do
          expect(Homeland::Markdown.call("@huacnlee hello @ruby_box")).to eq('<p><a href="/huacnlee" class="user-mention" title="@huacnlee"><i>@</i>huacnlee</a> hello <a href="/ruby_box" class="user-mention" title="@ruby_box"><i>@</i>ruby_box</a></p>')
        end

        it "should support ul,ol" do
          expect(Homeland::Markdown.call("* Ruby on Rails\n* Sinatra").delete("\n")).to eq("<ul><li>Ruby on Rails</li><li>Sinatra</li></ul>")
          expect(Homeland::Markdown.call("1. Ruby on Rails\n2. Sinatra").delete("\n")).to eq("<ol><li>Ruby on Rails</li><li>Sinatra</li></ol>")
        end

        it "should email neer Chinese chars can work" do
          # 次处要保留 在某些场景下面 email 后面紧接中文逗号会出现编码异常，而导致错误
          expect(Homeland::Markdown.call("可以给我邮件 monster@gmail.com，")).to eq("<p>可以给我邮件 monster@gmail.com，</p>")
        end

        it "should link mentioned floor" do
          expect(Homeland::Markdown.call("#3楼很强大")).to eq(
            '<p><a href="#reply3" class="at_floor" data-floor="3">#3楼</a>很强大</p>'
          )
        end

        it "should right encoding with #1楼 @ichord 刚刚发布，有点问题" do
          expect(Homeland::Markdown.call("#1楼 @ichord 刚刚发布，有点问题")).to eq(
            %(<p><a href="#reply1" class="at_floor" data-floor="1">#1楼</a> <a href="/ichord" class="user-mention" title="@ichord"><i>@</i>ichord</a> 刚刚发布，有点问题</p>)
          )
        end

        it "should wrap break line" do
          expect(Homeland::Markdown.call("line 1\nline 2")).to eq(
            "<p>line 1\nline 2</p>"
          )
        end

        it "should support inline code" do
          expect(Homeland::Markdown.call("This is `Ruby`")).to eq("<p>This is <code>Ruby</code></p>")
          expect(Homeland::Markdown.call("This is`Ruby`")).to eq("<p>This is<code>Ruby</code></p>")
        end

        it "should highlight code block" do
          expect(Homeland::Markdown.call("```ruby\nclass Hello\n\nend\n```")).to eq(
            %(<div class="highlight"><pre class="highlight ruby"><code><span class="k">class</span> <span class="nc">Hello</span>\n\n<span class="k">end</span>\n</code></pre></div>)
          )
        end

        it "should be able to identigy Ruby or RUBY as ruby language" do
          %w[Ruby RUBY].each do |lang|
            expect(Homeland::Markdown.call("```#{lang}\nclass Hello\nend\n```")).to eq(
              %(<div class="highlight"><pre class="highlight ruby"><code><span class="k">class</span> <span class="nc">Hello</span>\n<span class="k">end</span>\n</code></pre></div>)
            )
          end
        end

        it "should highlight code block after the content" do
          expect(Homeland::Markdown.call("this code:\n```\ngem install rails\n```\n")).to eq(
            %(<p>this code:</p>\n<div class="highlight"><pre class="highlight plaintext"><code>gem install rails\n</code></pre></div>)
          )
        end

        it "should highlight code block without language" do
          expect(Homeland::Markdown.call("```\ngem install ruby\n```").delete("\n")).to eq(
            %(<div class="highlight"><pre class="highlight plaintext"><code>gem install ruby</code></pre></div>)
          )
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
          expect(Homeland::Markdown.call(code)).to eq(Homeland::Markdown.call(expect_code))
        end

        it "should not filter underscore" do
          expect(Homeland::Markdown.call("ruby_china_image `ruby_china_image`")).to eq("<p>ruby_china_image <code>ruby_china_image</code></p>")
          expect(Homeland::Markdown.call("```\nruby_china_image\n```")).to eq(
            %(<div class="highlight"><pre class="highlight plaintext"><code>ruby_china_image\n</code></pre></div>)
          )
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
          it { is_expected.to eq(%(<p><a href="#reply1" class="at_floor" data-floor="1">#1楼</a> <a href="/ichord" class="user-mention" title="@ichord"><i>@</i>ichord</a> 刚刚发布，有点问题</p>)) }
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
          expect(doc.css("a").size).to eq(1)
          expect(doc.inner_html).to eq(%(<p><a href="/foo" class="user-mention" title="@foo"><i>@</i>foo</a></p>))
        end
      end

      context "@_underscore_ in text" do
        let(:raw) { "@_underscore_" }

        specify { expect(doc.inner_html).to eq(%(<p><a href="/_underscore_" class="user-mention" title="@_underscore_"><i>@</i>_underscore_</a></p>)) }
      end

      context "@foo.bar in text" do
        let(:raw) { "@foo.bar ss" }

        specify { expect(doc.inner_html).to eq(%(<p><a href="/foo.bar" class="user-mention" title="@foo.bar"><i>@</i>foo.bar</a> ss</p>)) }
      end

      context "@__underscore__ in text" do
        let(:raw) { "@__underscore__" }

        specify { expect(doc.inner_html).to eq(%(<p><a href="/__underscore__" class="user-mention" title="@__underscore__"><i>@</i>__underscore__</a></p>)) }
      end

      context "@ruby-china in text" do
        let(:raw) { "@ruby-china" }
        specify { expect(doc.inner_html).to eq(%(<p><a href="/ruby-china" class="user-mention" title="@ruby-china"><i>@</i>ruby-china</a></p>)) }
      end

      context "@small_fish__ in text" do
        let(:raw) { "@small_fish__" }
        specify { expect(doc.inner_html).to eq(%(<p><a href="/small_fish__" class="user-mention" title="@small_fish__"><i>@</i>small_fish__</a></p>)) }
      end

      context "@small_fish__ in code block" do
        let(:raw) { "`@small_fish__`" }
        specify { expect(doc.css("code").first.inner_html).to eq("@small_fish__") }
      end

      context "@small_fish__ in ruby code block" do
        let(:raw) do
          <<~MD
            ```ruby
            @small_fish__ = 100
            ```
          MD
        end

        specify { expect(doc.search("pre code").children[0].inner_html).to eq("@small_fish__") }
      end

      context "@user in code" do
        let(:raw) { "`@user`" }

        specify { expect(doc.css("a")).to be_empty }
        specify { expect(doc.css("code").inner_html).to eq("@user") }
      end

      context "@user in block code" do
        let(:raw) do
          <<~MD
            ```
            @user
            ```
          MD
        end

        specify { expect(doc.css("a")).to be_empty }
        specify { expect(doc.css("pre code").inner_text).to eq("@user\n") }
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
          expect(doc.to_html).to include("var")
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
          expect(doc.to_html).to include("var")
        end
      end

      context "@user in link" do
        let(:raw) { "http://medium.com/@user/foo" }
        specify { expect(doc.css(".user-mention")).to be_empty }
      end
    end

    # }}}

    # {{{ describe mention floor

    describe "mention floor" do
      context " #12f in text" do
        let(:raw) { "#12f" }

        it "has a link" do
          expect(doc.css("a").size).to eq(1)
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

        specify { expect(doc.css("a")).to be_empty }
        specify { expect(doc.css("code").inner_html).to eq("#12f") }
      end

      context " #12f in block code" do
        let(:raw) do
          <<~MD
            ```
            #12f
            ```
          MD
        end

        specify { expect(doc.css("a")).to be_empty }
        specify { expect(doc.css("pre code").inner_html).to eq("#12f\n") }
      end
    end

    # }}}

    # {{{ describe 'emoji'

    describe "emoji" do
      context ":apple: in text" do
        let(:raw) { ":apple:" }

        it "has a image" do
          expect(doc.css("img").size).to eq(1)
        end

        describe "the image" do
          subject { doc.css("img").first }

          describe "[:src]" do
            subject { super()[:src] }
            it { is_expected.to eq("https://twemoji.b0.upaiyun.com/2/svg/1f34e.svg") }
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
        specify { expect(doc.css("img").first[:title]).to eq(":-1:") }
      end
      context ":arrow_lower_left:" do
        let(:raw) { ":arrow_lower_left:" }
        specify { expect(doc.css("img").first[:title]).to eq(":arrow_lower_left:") }
      end

      context ":apple: in code" do
        let(:raw) { "`:apple:`" }

        specify { expect(doc.css("a")).to be_empty }
        specify { expect(doc.css("code").inner_html).to eq(":apple:") }
      end

      context ":apple: in block code" do
        let(:raw) do
          <<~MD
            ```
            :apple:
            ```
          MD
        end

        specify { expect(doc.css("a")).to be_empty }
        specify { expect(doc.css("pre code").inner_html).to eq(":apple:\n") }
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

        specify { expect(doc.css("pre").attr("class").value).to eq("highlight plaintext") }
      end

      context "```ruby use with code" do
        let(:raw) do
          %(```ruby
          class Foo; end
          ```)
        end

        specify { expect(doc.css("pre").attr("class").value).to eq("highlight ruby") }
      end

      context 'indent in raw with \t' do
        let(:raw) { "\t\tclass Foo; end" }

        specify { expect(doc.css("pre")).to be_empty }
      end

      context "indent in raw with space" do
        let(:raw) { "    class Foo; end" }

        specify { expect(doc.css("pre")).to be_empty }
      end
    end

    describe "list" do
      let(:raw) do
        %(foo\n- 123\n- 456)
      end

      it do
        expect(doc.inner_html).to eq(%(<p>foo</p>\n\n<ul>\n<li>123</li>\n<li>456</li>\n</ul>))
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

      it { expect(doc.inner_html).to eq "<div class=\"table-responsive\"><table class=\"table table-bordered table-striped\">\n<tr>\n<th>header 1</th>\n<th>header 3</th>\n</tr>\n<tr>\n<td>cell 1</td>\n<td>cell 2</td>\n</tr>\n<tr>\n<td>cell 3</td>\n<td>cell 4</td>\n</tr>\n</table></div>" }
    end

    describe "embed" do
      describe "Youtube" do
        let(:raw) do
          %(https://www.youtube.com/watch?v=SccR4kqBvy8)
        end

        it { expect(doc.inner_html).to eq "<p><span class=\"embed-responsive embed-responsive-16by9\"><iframe class=\"embed-responsive-item\" src=\"//www.youtube.com/embed/SccR4kqBvy8\" allowfullscreen></iframe></span></p>" }
      end

      describe "Vimeo" do
        let(:raw) do
          %(https://vimeo.com/159449591)
        end

        it { expect(doc.inner_html).to eq %(<p><span class="embed-responsive embed-responsive-16by9"><iframe class="embed-responsive-item" src="https://player.vimeo.com/video/159449591" allowfullscreen></iframe></span></p>) }
      end

      describe "Youku" do
        let(:raw) do
          %(http://v.youku.com/v_show/id_XMjUzMTk4NTk2MA==.html?from=y1.3-idx-beta-1519-23042.223465.1-1&spm=a2hww.20023042.m_223465.5~5~5~5~5~5~A#paction)
        end

        it { expect(doc.inner_html).to eq "<p><span class=\"embed-responsive embed-responsive-16by9\"><iframe class=\"embed-responsive-item\" src=\"//player.youku.com/embed/XMjUzMTk4NTk2MA==\" allowfullscreen></iframe></span></p>" }
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
          expect(subject).to eq '<p><a href="https://www.flickr.com/photos/123590011@N08/sets/72157644587013882/" rel="nofollow" target="_blank">https://www.flickr.com/photos/123590011@N08/sets/72157644587013882/</a></p>'
        end
      end
    end

    describe "Full example" do
      let(:raw) { File.open(Rails.root.join("spec/fixtures/markdown/raw.md")).read }
      let(:out) { File.open(Rails.root.join("spec/fixtures/markdown/out.html")).read }

      it "should work" do
        expect(doc.inner_html).to eq(out.strip)
      end
    end
  end
end
