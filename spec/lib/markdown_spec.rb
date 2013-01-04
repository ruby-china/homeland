require 'nokogiri'
require File.expand_path('../../../lib/markdown', __FILE__)

describe 'markdown' do
  let(:upload_url) { '' }
  before do
    MarkdownTopicConverter.stub(:upload_url).and_return(upload_url)
  end

  describe MarkdownTopicConverter do
    let(:raw) { '' }
    let!(:doc) { Nokogiri::HTML.fragment(MarkdownTopicConverter.format(raw)) }
    subject { doc }

    # {{{ describe '@user'

    describe '@user' do
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
          its(:text) { should == '@user' }
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
          its(:text) { should == '@_underscore_' }
        end
      end

      context '@user in code' do
        let(:raw) { '`@user`' }

        specify { doc.css('a').should be_empty }
        specify { doc.css('code').text.should == '@user' }
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
        specify { doc.css('pre').text.should == '@user' }
      end
    end

    # }}}

    # {{{ describe '#12f'

    describe ' #12f' do
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
          its(:text) { should == '#12f' }
        end
      end

      context ' #12f in code' do
        let(:raw) { '`#12f`' }

        specify { doc.css('a').should be_empty }
        specify { doc.css('code').text.should == '#12f' }
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
        specify { doc.css('pre').text.should == '#12f' }
      end
    end

    # }}}

    # {{{ describe ':apple'

    describe ':apple:' do
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
        specify { doc.css('code').text.should == ':apple:' }
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
        specify { doc.css('pre').text.should == ':apple:' }
      end
    end

    # }}}
  end
end
