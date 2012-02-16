module Redcarpet
  module Render
    class HTMLwithSyntaxHighlight < HTML
      def initialize(extensions={})
        super(extensions.merge(:xhtml => true, :hard_wrap => true, :filter_html => true))
      end

      def block_code(code, language)
        language = 'text' if language.blank?
        begin
          Pygments.highlight(code, :lexer => language, :formatter => 'html', :options => {:encoding => 'utf-8'})
        rescue
          Pygments.highlight(code, :lexer => 'text', :formatter => 'html', :options => {:encoding => 'utf-8'})
        end
      end
    end

    class NofollowAutoLink < HTMLwithSyntaxHighlight
      def autolink(link, link_type)
        "<a href=\"#{link}\" rel=\"nofollow\" target=\"_blank\">#{link}</a>"
      end
    end
  end
end

class MarkdownConverter
  include Singleton

  def self.convert(text)
    self.instance.convert(text)
  end

  def convert(text)
    @converter.render(text)
  end

  private
  def initialize
    @converter = Redcarpet::Markdown.new(Redcarpet::Render::HTMLwithSyntaxHighlight.new, {
        :autolink => true,
        :fenced_code_blocks => true
      })
  end
end

class MarkdownTopicConverter < MarkdownConverter
  private
  def initialize
    @converter = Redcarpet::Markdown.new(Redcarpet::Render::NofollowAutoLink.new, {
        :autolink => true,
        :fenced_code_blocks => true,
        :strikethrough => true,
        :space_after_headers => true
      })
  end
end
