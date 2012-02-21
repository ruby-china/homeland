# coding: utf-8
require 'rails_autolink'
module Redcarpet
  module Render
    class HTMLwithSyntaxHighlight < HTML
      def initialize(extensions={})
        super(extensions.merge(:xhtml => true, 
                               :no_styles => true, 
                               :filter_html => true, 
                               :hard_wrap => true))
      end

      def block_code(code, language)
        language = 'text' if language.blank?
        begin
          Pygments.highlight(code, :lexer => language, :formatter => 'html', :options => {:encoding => 'utf-8'})
        rescue
          Pygments.highlight(code, :lexer => 'text', :formatter => 'html', :options => {:encoding => 'utf-8'})
        end
      end
      
      def autolink(link, link_type)
        # return link
        if link_type.to_s == "email"
          link          
        else
          "<a href=\"#{link}\" rel=\"nofollow\" target=\"_blank\">#{link}</a>"
        end        
      end
    end
    
    class HTMLwithTopic < HTMLwithSyntaxHighlight
      # Topic 里面，所有的 head 改为 h4 显示
      def header(text, header_level)
        "<h4>#{text}</h4>"
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
        :fenced_code_blocks => true,
        :no_intra_emphasis => true
      })
  end
end

class MarkdownTopicConverter < MarkdownConverter
  private
  def initialize
    @converter = Redcarpet::Markdown.new(Redcarpet::Render::HTMLwithTopic.new, {
        :autolink => true,
        :fenced_code_blocks => true,
        :strikethrough => true,
        :space_after_headers => true,
        :no_intra_emphasis => true
      })
  end
end
