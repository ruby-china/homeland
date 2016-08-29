require 'rails_helper'

describe TopicsHelper, type: :helper do
  describe 'markdown' do
    it 'should right with Chinese neer URL' do
      # TODO: 这行是由于 Redcarpet 的 auto_link 方法转换连起来的会有编码错误
      #  @huacnlee提醒说在某些环境下面，下面测试会Pass。所以有可能在你的测试环境会失败。
      expect(helper.markdown('此版本并非线上的http://yavaeye.com 的源码.')).to eq(
        '<p>此版本并非线上的<a href="http://yavaeye.com" rel="nofollow" target="_blank">http://yavaeye.com</a> 的源码.</p>'
      )
      expect(helper.markdown('http://foo.com,的???')).to eq(
        '<p><a href="http://foo.com," rel="nofollow" target="_blank">http://foo.com,</a>的???</p>'
      )
      expect(helper.markdown('http://foo.com，的???')).to eq(
        '<p><a href="http://foo.com" rel="nofollow" target="_blank">http://foo.com</a>，的???</p>'
      )
      expect(helper.markdown('http://foo.com。的???')).to eq(
        '<p><a href="http://foo.com" rel="nofollow" target="_blank">http://foo.com</a>。的???</p>'
      )
      expect(helper.markdown('http://foo.com；的???')).to eq(
        '<p><a href="http://foo.com" rel="nofollow" target="_blank">http://foo.com</a>；的???</p>'
      )
    end

    context 'bad html' do
      it 'filter script' do
        expect(helper.markdown('<script>alert()</script> foo')).to eq('<p>alert() foo</p>')
      end

      it 'filter style' do
        expect(helper.markdown('<style>.body {}</style> foo')).to eq('<p>.body {} foo</p>')
      end
    end

    it 'should match complex urls' do
      expect(helper.markdown('http://movie.douban.com/tag/%E7%BE%8E%E5%9B%BD')).to eq(
        '<p><a href="http://movie.douban.com/tag/%E7%BE%8E%E5%9B%BD" rel="nofollow" target="_blank">http://movie.douban.com/tag/%E7%BE%8E%E5%9B%BD</a></p>'
      )
      expect(helper.markdown('http://ruby-china.org/self_posts/11?datas=20,33|100&format=.jpg')).to eq(
        '<p><a href="http://ruby-china.org/self_posts/11?datas=20,33%7C100&amp;format=.jpg" rel="nofollow" target="_blank">http://ruby-china.org/self_posts/11?datas=20,33|100&amp;format=.jpg</a></p>'
      )
      expect(helper.markdown('https://g.l/b/?fromgroups#!searchin/gitlabhq/self$20regist/gitlabhq/5ha_FyX-Pr4/VNZTPnSN0S4J')).to eq(
        '<p><a href="https://g.l/b/?fromgroups#!searchin/gitlabhq/self%2420regist/gitlabhq/5ha_FyX-Pr4/VNZTPnSN0S4J" rel="nofollow" target="_blank">https://g.l/b/?fromgroups#!searchin/gitlabhq/self$20regist/gitlabhq/5ha_FyX-Pr4/VNZTPnSN0S4J</a></p>'
      )
    end

    it 'should bold text ' do
      expect(helper.markdown('**bold**')).to eq('<p><strong>bold</strong></p>')
    end

    it 'should italic text' do
      expect(helper.markdown('*italic*')).to eq('<p><em>italic</em></p>')
    end

    it 'should strikethrough text' do
      expect(helper.markdown('~~strikethrough~~')).to eq('<p><del>strikethrough</del></p>')
    end

    it 'should auto link' do
      expect(helper.markdown('this is a link: http://ruby-china.org test')).to eq(
        '<p>this is a link: <a href="http://ruby-china.org" rel="nofollow" target="_blank">http://ruby-china.org</a> test</p>'
      )
    end

    it 'should auto link' do
      expect(helper.markdown('http://ruby-china.org/~users')).to eq(
        '<p><a href="http://ruby-china.org/~users" rel="nofollow" target="_blank">http://ruby-china.org/~users</a></p>'
      )
    end

    it 'should auto link with Chinese' do
      expect(helper.markdown('靠着中文http://foo.com，')).to eq(
        "<p>靠着中文<a href=\"http://foo.com\" rel=\"nofollow\" target=\"_blank\">http://foo.com</a>，</p>"
      )
    end

    it 'should link mentioned user' do
      user = create(:user)
      expect(helper.markdown("hello @#{user.name} @b @a @#{user.name}")).to eq(
        "<p>hello <a href=\"/#{user.name}\" class=\"at_user\" title=\"@#{user.name}\"><i>@</i>#{user.name}</a> <a href=\"/b\" class=\"at_user\" title=\"@b\"><i>@</i>b</a> <a href=\"/a\" class=\"at_user\" title=\"@a\"><i>@</i>a</a> <a href=\"/#{user.name}\" class=\"at_user\" title=\"@#{user.name}\"><i>@</i>#{user.name}</a></p>"
      )
    end

    it 'should link mentioned user at first of line' do
      expect(helper.markdown('@huacnlee hello @ruby_box')).to eq('<p><a href="/huacnlee" class="at_user" title="@huacnlee"><i>@</i>huacnlee</a> hello <a href="/ruby_box" class="at_user" title="@ruby_box"><i>@</i>ruby_box</a></p>')
    end

    it 'should support ul,ol' do
      expect(helper.markdown("* Ruby on Rails\n* Sinatra").delete("\n")).to eq('<ul><li>Ruby on Rails</li><li>Sinatra</li></ul>')
      expect(helper.markdown("1. Ruby on Rails\n2. Sinatra").delete("\n")).to eq('<ol><li>Ruby on Rails</li><li>Sinatra</li></ol>')
    end

    it 'should email neer Chinese chars can work' do
      # 次处要保留 在某些场景下面 email 后面紧接中文逗号会出现编码异常，而导致错误
      expect(helper.markdown('可以给我邮件 monster@gmail.com，')).to eq('<p>可以给我邮件 monster@gmail.com，</p>')
    end

    it 'should link mentioned floor' do
      expect(helper.markdown('#3楼很强大')).to eq(
        '<p><a href="#reply3" class="at_floor" data-floor="3">#3楼</a>很强大</p>'
      )
    end

    it 'should right encoding with #1楼 @ichord 刚刚发布，有点问题' do
      expect(helper.markdown('#1楼 @ichord 刚刚发布，有点问题')).to eq(
        %(<p><a href="#reply1" class="at_floor" data-floor="1">#1楼</a> <a href="/ichord" class="at_user" title="@ichord"><i>@</i>ichord</a> 刚刚发布，有点问题</p>)
      )
    end

    it 'should wrap break line' do
      expect(helper.markdown("line 1\nline 2")).to eq(
        "<p>line 1<br>\nline 2</p>"
      )
    end

    it 'should support inline code' do
      expect(helper.markdown('This is `Ruby`')).to eq('<p>This is <code>Ruby</code></p>')
      expect(helper.markdown('This is`Ruby`')).to eq('<p>This is<code>Ruby</code></p>')
    end

    it 'should highlight code block' do
      expect(helper.markdown("```ruby\nclass Hello\n\nend\n```")).to eq(
        %(<pre class=\"highlight ruby\"><code><span class=\"k\">class</span> <span class=\"nc\">Hello</span>\n\n<span class=\"k\">end</span></code></pre>)
      )
    end

    it 'should be able to identigy Ruby or RUBY as ruby language' do
      %w(Ruby RUBY).each do |lang|
        expect(helper.markdown("```#{lang}\nclass Hello\nend\n```")).to eq(
          %(<pre class=\"highlight ruby\"><code><span class=\"k\">class</span> <span class=\"nc\">Hello</span>\n<span class=\"k\">end</span></code></pre>)
        )
      end
    end

    it 'should highlight code block after the content' do
      expect(helper.markdown("this code:\n```\ngem install rails\n```\n")).to eq(
        %(<p>this code:</p>\n<pre class=\"highlight plaintext\"><code>gem install rails</code></pre>)
      )
    end

    it 'should highlight code block without language' do
      expect(helper.markdown("```\ngem install ruby\n```").delete("\n")).to eq(
        %(<pre class=\"highlight plaintext\"><code>gem install ruby</code></pre>)
      )
    end

    it 'should not filter underscore' do
      expect(helper.markdown('ruby_china_image `ruby_china_image`')).to eq('<p>ruby_china_image <code>ruby_china_image</code></p>')
      expect(helper.markdown("```\nruby_china_image\n```")).to eq(
        %(<pre class=\"highlight plaintext\"><code>ruby_china_image</code></pre>)
      )
    end
  end

  describe 'topic_favorite_tag' do
    let(:user) { create :user }
    let(:topic) { create :topic }

    it 'should run with nil param' do
      allow(helper).to receive(:current_user).and_return(nil)
      expect(helper.topic_favorite_tag(nil)).to eq('')
    end

    it 'should result when logined user did not favorite topic' do
      allow(user).to receive(:favorite_topic_ids).and_return([])
      allow(helper).to receive(:current_user).and_return(user)
      res = helper.topic_favorite_tag(topic)
      expect(res).to eq("<a title=\"收藏\" class=\"bookmark \" data-id=\"1\" href=\"#\"><i class=\"fa fa-bookmark\"></i> 收藏</a>")
    end

    it 'should result when logined user favorited topic' do
      allow(user).to receive(:favorite_topic_ids).and_return([topic.id])
      allow(helper).to receive(:current_user).and_return(user)
      expect(helper.topic_favorite_tag(topic)).to eq("<a title=\"取消收藏\" class=\"bookmark active\" data-id=\"1\" href=\"#\"><i class=\"fa fa-bookmark\"></i> 收藏</a>")
    end

    it 'should result blank when unlogin user' do
      allow(helper).to receive(:current_user).and_return(nil)
      expect(helper.topic_favorite_tag(topic)).to eq('')
    end
  end

  describe 'topic_title_tag' do
    let(:topic) { create :topic, title: 'test title' }
    let(:user) { create :user }

    it 'should return topic_was_deleted without a topic' do
      expect(helper.topic_title_tag(nil)).to eq(t('topics.topic_was_deleted'))
    end

    it 'should return title with a topic' do
      expect(helper.topic_title_tag(topic)).to eq("<a title=\"#{topic.title}\" href=\"/topics/#{topic.id}\">#{topic.title}</a>")
    end
  end

  describe 'topic_follow_tag' do
    let(:topic) { create :topic }
    let(:user) { create :user }

    it 'should return empty when current_user is nil' do
      allow(helper).to receive(:current_user).and_return(nil)
      expect(helper.topic_follow_tag(topic)).to eq('')
    end

    it 'should return empty when is owner' do
      allow(helper).to receive(:current_user).and_return(topic.user)
      expect(helper.topic_follow_tag(topic)).to eq('')
    end

    it 'should return empty when topic is nil' do
      allow(helper).to receive(:current_user).and_return(user)
      expect(helper.topic_follow_tag(nil)).to eq('')
    end

    context 'was unfollow' do
      it 'should work' do
        allow(helper).to receive(:current_user).and_return(user)
        expect(helper.topic_follow_tag(topic)).to eq "<a data-id=\"#{topic.id}\" class=\"follow\" href=\"#\"><i class=\"fa fa-eye\"></i> 关注</a>"
      end
    end

    context 'was active' do
      it 'should work' do
        allow(helper).to receive(:current_user).and_return(user)
        allow(topic).to receive(:follower_ids).and_return([user.id])
        expect(helper.topic_follow_tag(topic)).to eq "<a data-id=\"#{topic.id}\" class=\"follow active\" href=\"#\"><i class=\"fa fa-eye\"></i> 关注</a>"
      end
    end
  end
end
