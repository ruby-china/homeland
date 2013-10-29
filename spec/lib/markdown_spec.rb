# coding: utf-8
require 'spec_helper'

describe 'markdown' do
  let(:upload_url) { '' }
  before do
    MarkdownTopicConverter.instance.stub(:upload_url).and_return(upload_url)
  end

  describe MarkdownTopicConverter do
    let(:raw) { '' }
    let!(:doc) { Nokogiri::HTML.fragment(MarkdownTopicConverter.format(raw)) }
    subject { doc }

    # {{{ describe 'mention user'
    
    describe "encoding with Chinese chars" do
      context "a simple" do
        let(:raw) { '#1楼 @ichord 刚刚发布，有点问题' }
        its(:inner_html) { should == %(<p><a href="#reply1" class="at_floor" data-floor="1">#1楼</a> <a href="/ichord" class="at_user" title="@ichord"><i>@</i>ichord</a> 刚刚发布，有点问题</p>) }
      end
    end

    describe 'at user' do
      context '@user in text' do
        let(:raw) { '@user' }

        it 'has a link' do
          doc.css('a').should have(1).item
        end

        describe 'the link' do
          subject { doc.css('a').first }

          its([:href]) { should == '/user' }
          its([:class]) { should == 'at_user' }
          its([:title]) { should == '@user' }
          its(:inner_html) { should == '<i>@</i>user' }
        end
      end

      context '@_underscore_ in text' do
        let(:raw) { '@_underscore_' }

        it 'has a link' do
          doc.css('a').should have(1).item
        end

        describe 'the link' do
          subject { doc.css('a').first }

          its([:href]) { should == '/_underscore_' }
          its([:class]) { should == 'at_user' }
          its([:title]) { should == '@_underscore_' }
          its(:inner_html) { should == '<i>@</i>_underscore_' }
        end
      end

      context '@__underscore__ in text' do
        let(:raw) { '@__underscore__' }

        it 'has a link' do
          doc.css('a').should have(1).item
        end

        describe 'the link' do
          subject { doc.css('a').first }

          its([:href]) { should == '/__underscore__' }
          its([:class]) { should == 'at_user' }
          its([:title]) { should == '@__underscore__' }
          its(:inner_html) { should == '<i>@</i>__underscore__' }
        end
      end

      context '@small_fish__ in text' do
        let(:raw) { '@small_fish__' }
        specify { doc.css('a').first.inner_html.should == '<i>@</i>small_fish__' }
      end

      context '@small_fish__ in code block' do
        let(:raw) { '`@small_fish__`' }
        specify { doc.css('code').first.inner_html.should == '@small_fish__' }
      end

      context '@small_fish__ in ruby code block' do
        let(:raw) {
          <<-MD.gsub(/^ {12}/, '')
            ```ruby
            @small_fish__ = 100
            ```
          MD
        }

        specify { doc.search('pre').children[0].inner_html.should == '@small_fish__' }
      end

      context '@user in code' do
        let(:raw) { '`@user`' }

        specify { doc.css('a').should be_empty }
        specify { doc.css('code').inner_html.should == '@user' }
      end

      context '@user in block code' do
        let(:raw) {
          <<-MD.gsub(/^ {12}/, '')
            ```
            @user
            ```
          MD
        }

        specify { doc.css('a').should be_empty }
        specify { doc.css('pre').inner_html.should == "@user\n" }
      end

      context '@var in coffeescript' do
        let(:raw) {
          <<-MD.gsub(/^ {12}/, '')
            ```coffeescript
            @var
            ```
          MD
        }

        it 'should not leave it as placeholder' do
          doc.to_html.should include('var')
        end
      end
    end

    # }}}

    # {{{ describe mention floor

    describe 'mention floor' do
      context ' #12f in text' do
        let(:raw) { '#12f' }

        it 'has a link' do
          doc.css('a').should have(1).item
        end

        describe 'the link' do
          subject { doc.css('a').first }

          its([:href]) { should == '#reply12' }
          its([:class]) { should == 'at_floor' }
          its(['data-floor']) { should == '12' }
          its(:inner_html) { should == '#12f' }
        end
      end

      context ' #12f in code' do
        let(:raw) { '`#12f`' }

        specify { doc.css('a').should be_empty }
        specify { doc.css('code').inner_html.should == '#12f' }
      end

      context ' #12f in block code' do
        let(:raw) {
          <<-MD.gsub(/^ {12}/, '')
            ```
            #12f
            ```
          MD
        }

        specify { doc.css('a').should be_empty }
        specify { doc.css('pre').inner_html.should == "#12f\n" }
      end
    end

    # }}}

    # {{{ describe 'emoji'

    describe 'emoji' do
      context ':apple: in text' do
        let(:raw) { ':apple:' }

        it 'has a image' do
          doc.css('img').should have(1).item
        end

        describe 'the image' do
          subject { doc.css('img').first }

          its([:src]) { should == "#{upload_url}/assets/emojis/apple.png" }
          its([:class]) { should == 'emoji' }
          its([:title]) { should == ':apple:' }
        end
      end

      context ':-1:' do
        let(:raw) { ':-1:' }
        specify { doc.css('img').first[:title].should == ':-1:' }
      end
      context ':arrow_lower_left:' do
        let(:raw) { ':arrow_lower_left:' }
        specify { doc.css('img').first[:title].should == ':arrow_lower_left:' }
      end

      context ':apple: in code' do
        let(:raw) { '`:apple:`' }

        specify { doc.css('a').should be_empty }
        specify { doc.css('code').inner_html.should == ':apple:' }
      end

      context ':apple: in block code' do
        let(:raw) {
          <<-MD.gsub(/^ {12}/, '')
            ```
            :apple:
            ```
          MD
        }

        specify { doc.css('a').should be_empty }
        specify { doc.css('pre').inner_html.should == ":apple:\n" }
      end
    end

    # }}}
    
    describe 'The code' do
      context '``` use with code' do
        let(:raw) {
          %(```
          class Foo; end
          ```)
        }
        
        specify { doc.css('pre').attr("class").value.should == "highlight plaintext" }
      end
      
      context '```ruby use with code' do
        let(:raw) {
          %(```ruby
          class Foo; end
          ```)
        }
        
        specify { doc.css('pre').attr("class").value.should == "highlight ruby" }
      end
      
      context 'indent in raw with \t' do
        let(:raw) { "\t\tclass Foo; end" }
        
        specify { doc.css('pre').should be_empty }
      end
      
      context 'indent in raw with space' do
        let(:raw) { "    class Foo; end" }
        
        specify { doc.css('pre').should be_empty }
      end
    end
    
    describe 'Escape HTML tags' do
      context '<xxx> or a book names' do
        let(:raw) { "<Enterprise Integration Patterns> book" }
        its(:inner_html) { should == "<p>&lt;Enterprise Integration Patterns&gt; book</p>" }
      end
      
      context '<img> tag' do
        let(:raw) { "<img src='aaa.jpg' /> aaa" }
        its(:inner_html) { should == "<p>&lt;img src='aaa.jpg' /&gt; aaa</p>" }
      end
      
      context '<b> tag' do
        let(:raw) { "<b>aaa</b>" }
        its(:inner_html) { should == "<p>&lt;b&gt;aaa&lt;/b&gt;</p>" }
      end
    end
  end
end
