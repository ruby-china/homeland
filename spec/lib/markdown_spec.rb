# coding: utf-8
require 'rails_helper'

describe 'markdown' do
  let(:upload_url) { '' }
  before do
    allow(MarkdownTopicConverter.instance).to receive(:upload_url).and_return(upload_url)
  end

  describe MarkdownTopicConverter do
    let(:raw) { '' }
    let!(:doc) { Nokogiri::HTML.fragment(MarkdownTopicConverter.format(raw)) }
    subject { doc }

    # {{{ describe 'mention user'
    
    describe "encoding with Chinese chars" do
      context "a simple" do
        let(:raw) { '#1楼 @ichord 刚刚发布，有点问题' }

        describe '#inner_html' do
          subject { super().inner_html }
          it { is_expected.to eq(%(<p><a href="#reply1" class="at_floor" data-floor="1">#1楼</a> <a href="/ichord" class="at_user" title="@ichord"><i>@</i>ichord</a> 刚刚发布，有点问题</p>)) }
        end
      end
    end
    
    describe 'strikethrough' do
      let(:raw) { "some ~~strikethrough~~ text" }

      describe '#inner_html' do
        subject { super().inner_html }
        it { is_expected.to eq(%(<p>some <del>strikethrough</del> text</p>)) }
      end
    end

    describe 'strong' do
      let(:raw) { "some **strong** text" }

      describe '#inner_html' do
        subject { super().inner_html }
        it { is_expected.to eq(%(<p>some <strong>strong</strong> text</p>)) }
      end
    end
    
    describe 'at user' do
      context '@user in text' do
        let(:raw) { '@user' }

        it 'has a link' do
          expect(doc.css('a').size).to eq(1)
        end

        describe 'the link' do
          subject { doc.css('a').first }

          describe '[:href]' do
            subject { super()[:href] }
            it { is_expected.to eq('/user') }
          end

          describe '[:class]' do
            subject { super()[:class] }
            it { is_expected.to eq('at_user') }
          end

          describe '[:title]' do
            subject { super()[:title] }
            it { is_expected.to eq('@user') }
          end

          describe '#inner_html' do
            subject { super().inner_html }
            it { is_expected.to eq('<i>@</i>user') }
          end
        end
      end

      context '@_underscore_ in text' do
        let(:raw) { '@_underscore_' }

        it 'has a link' do
          expect(doc.css('a').size).to eq(1)
        end

        describe 'the link' do
          subject { doc.css('a').first }

          describe '[:href]' do
            subject { super()[:href] }
            it { is_expected.to eq('/_underscore_') }
          end

          describe '[:class]' do
            subject { super()[:class] }
            it { is_expected.to eq('at_user') }
          end

          describe '[:title]' do
            subject { super()[:title] }
            it { is_expected.to eq('@_underscore_') }
          end

          describe '#inner_html' do
            subject { super().inner_html }
            it { is_expected.to eq('<i>@</i>_underscore_') }
          end
        end
      end

      context '@__underscore__ in text' do
        let(:raw) { '@__underscore__' }

        it 'has a link' do
          expect(doc.css('a').size).to eq(1)
        end

        describe 'the link' do
          subject { doc.css('a').first }

          describe '[:href]' do
            subject { super()[:href] }
            it { is_expected.to eq('/__underscore__') }
          end

          describe '[:class]' do
            subject { super()[:class] }
            it { is_expected.to eq('at_user') }
          end

          describe '[:title]' do
            subject { super()[:title] }
            it { is_expected.to eq('@__underscore__') }
          end

          describe '#inner_html' do
            subject { super().inner_html }
            it { is_expected.to eq('<i>@</i>__underscore__') }
          end
        end
      end

      context '@small_fish__ in text' do
        let(:raw) { '@small_fish__' }
        specify { expect(doc.css('a').first.inner_html).to eq('<i>@</i>small_fish__') }
      end

      context '@small_fish__ in code block' do
        let(:raw) { '`@small_fish__`' }
        specify { expect(doc.css('code').first.inner_html).to eq('@small_fish__') }
      end

      context '@small_fish__ in ruby code block' do
        let(:raw) {
          <<-MD.gsub(/^ {12}/, '')
            ```ruby
            @small_fish__ = 100
            ```
          MD
        }

        specify { expect(doc.search('pre').children[0].inner_html).to eq('@small_fish__') }
      end

      context '@user in code' do
        let(:raw) { '`@user`' }

        specify { expect(doc.css('a')).to be_empty }
        specify { expect(doc.css('code').inner_html).to eq('@user') }
      end

      context '@user in block code' do
        let(:raw) {
          <<-MD.gsub(/^ {12}/, '')
            ```
            @user
            ```
          MD
        }

        specify { expect(doc.css('a')).to be_empty }
        specify { expect(doc.css('pre').inner_html).to eq("@user\n") }
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
          expect(doc.to_html).to include('var')
        end
      end
    end

    # }}}

    # {{{ describe mention floor

    describe 'mention floor' do
      context ' #12f in text' do
        let(:raw) { '#12f' }

        it 'has a link' do
          expect(doc.css('a').size).to eq(1)
        end

        describe 'the link' do
          subject { doc.css('a').first }

          describe '[:href]' do
            subject { super()[:href] }
            it { is_expected.to eq('#reply12') }
          end

          describe '[:class]' do
            subject { super()[:class] }
            it { is_expected.to eq('at_floor') }
          end

          describe "['data-floor']" do
            subject { super()['data-floor'] }
            it { is_expected.to eq('12') }
          end

          describe '#inner_html' do
            subject { super().inner_html }
            it { is_expected.to eq('#12f') }
          end
        end
      end

      context ' #12f in code' do
        let(:raw) { '`#12f`' }

        specify { expect(doc.css('a')).to be_empty }
        specify { expect(doc.css('code').inner_html).to eq('#12f') }
      end

      context ' #12f in block code' do
        let(:raw) {
          <<-MD.gsub(/^ {12}/, '')
            ```
            #12f
            ```
          MD
        }

        specify { expect(doc.css('a')).to be_empty }
        specify { expect(doc.css('pre').inner_html).to eq("#12f\n") }
      end
    end

    # }}}

    # {{{ describe 'emoji'

    describe 'emoji' do
      context ':apple: in text' do
        let(:raw) { ':apple:' }

        it 'has a image' do
          expect(doc.css('img').size).to eq(1)
        end

        describe 'the image' do
          subject { doc.css('img').first }

          describe '[:src]' do
            subject { super()[:src] }
            it { is_expected.to eq("#{upload_url}/assets/emojis/apple.png") }
          end

          describe '[:class]' do
            subject { super()[:class] }
            it { is_expected.to eq('emoji') }
          end

          describe '[:title]' do
            subject { super()[:title] }
            it { is_expected.to eq(':apple:') }
          end
        end
      end

      context ':-1:' do
        let(:raw) { ':-1:' }
        specify { expect(doc.css('img').first[:title]).to eq(':-1:') }
      end
      context ':arrow_lower_left:' do
        let(:raw) { ':arrow_lower_left:' }
        specify { expect(doc.css('img').first[:title]).to eq(':arrow_lower_left:') }
      end

      context ':apple: in code' do
        let(:raw) { '`:apple:`' }

        specify { expect(doc.css('a')).to be_empty }
        specify { expect(doc.css('code').inner_html).to eq(':apple:') }
      end

      context ':apple: in block code' do
        let(:raw) {
          <<-MD.gsub(/^ {12}/, '')
            ```
            :apple:
            ```
          MD
        }

        specify { expect(doc.css('a')).to be_empty }
        specify { expect(doc.css('pre').inner_html).to eq(":apple:\n") }
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
        
        specify { expect(doc.css('pre').attr("class").value).to eq("highlight plaintext") }
      end
      
      context '```ruby use with code' do
        let(:raw) {
          %(```ruby
          class Foo; end
          ```)
        }
        
        specify { expect(doc.css('pre').attr("class").value).to eq("highlight ruby") }
      end
      
      context 'indent in raw with \t' do
        let(:raw) { "\t\tclass Foo; end" }
        
        specify { expect(doc.css('pre')).to be_empty }
      end
      
      context 'indent in raw with space' do
        let(:raw) { "    class Foo; end" }
        
        specify { expect(doc.css('pre')).to be_empty }
      end
    end
    
    describe 'Escape HTML tags' do
      context '<xxx> or a book names' do
        let(:raw) { "<Enterprise Integration Patterns> book" }

        describe '#inner_html' do
          subject { super().inner_html }
          it { is_expected.to eq("<p>&lt;Enterprise Integration Patterns&gt; book</p>") }
        end
      end
      
      context '<img> tag' do
        let(:raw) { "<img src='aaa.jpg' /> aaa" }

        describe '#inner_html' do
          subject { super().inner_html }
          it { is_expected.to eq("<p>&lt;img src='aaa.jpg' /&gt; aaa</p>") }
        end
      end
      
      context '<b> tag' do
        let(:raw) { "<b>aaa</b>" }

        describe '#inner_html' do
          subject { super().inner_html }
          it { is_expected.to eq("<p>&lt;b&gt;aaa&lt;/b&gt;</p>") }
        end
      end

      context "<a> tag" do
        let(:raw) { "https://www.flickr.com/photos/123590011@N08/sets/72157644587013882/" }

        subject { super().inner_html }
        it "auto link with @ issue #322" do
          expect(subject).to eq "<p><a href=\"https://www.flickr.com/photos/123590011@N08/sets/72157644587013882/\" rel=\"nofollow\" target=\"_blank\">https://www.flickr.com/photos/123590011@N08/sets/72157644587013882/</a></p>"
        end
      end
    end
  end
end
