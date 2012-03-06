# coding: utf-8
require 'rails_autolink'
require 'iconv'
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
          begin
            # 防止 C 的 autolink 出来的内容有编码错误，万一有就直接跳过转换
            # 比如这句:
            # 此版本并非线上的http://yavaeye.com的源码.
            link.match(/.+?/)
          rescue
            return link
          end
          # Fix Chinese neer the URL
          bad_text = link.to_s.match(/[^\w\d:\/\-\,\$\!\_\.=\?&#+\|\%]+/im).to_s
          link = link.to_s.gsub(bad_text, '')
          "<a href=\"#{link}\" rel=\"nofollow\" target=\"_blank\">#{link}</a>#{bad_text}"
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
  def self.format(text)
    return '' if text.blank?

    self.convert_bbcode_img(text)
    
    # 如果 ``` 在刚刚换行的时候 Redcapter 无法生成正确，需要两个换行
    text.gsub!("\n```","\n\n```")
    
    result = self.convert(text)

    self.link_mention_floor(result)
    self.link_mention_user(result)

    return result.strip
  rescue => e
    puts "MarkdownTopicConverter.format ERROR: #{e}"
    return text
  end

  private
  # convert bbcode-style image tag [img]url[/img] to markdown syntax ![alt](url)
  def self.convert_bbcode_img(text)
    text.gsub!(/\[img\](.+?)\[\/img\]/i) {"![#{self.image_alt $1}](#{$1})"}
  end

  def self.image_alt(src)
    File.basename(src, '.*').capitalize
  end

  # convert '#N楼' to link
  def self.link_mention_floor(text)
    text.gsub!(/#(\d+)([楼樓Ff])/) { 
      %(<a href="#reply#{$1}" class="at_floor" data-floor="#{$1}">##{$1}#{$2}</a>)
    }
  end

  # convert '@user' to link
  # match any user even not exist.
  def self.link_mention_user(text)
    text.gsub!(/(^|[^a-zA-Z0-9_!#\$%&*@＠])@([a-zA-Z0-9_]{1,20})/io) { 
      %(#{$1}<a href="/users/#{$2}" class="at_user" title="@#{$2}"><i>@</i>#{$2}</a>)
    }
  end

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
