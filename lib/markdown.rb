# coding: utf-8
require 'rails_autolink'
require 'html/pipeline'

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
          bad_text = link.to_s.match(/[^\w:\/\-\,\$\!\.=\?&#+\|\%]+/im).to_s
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

module PipelineFilters
  class MarkdownFilter < HTML::Pipeline::TextFilter
    def initialize(text, context = nil, result = nil)
      super text, context, result
      # 如果 ``` 在刚刚换行的时候 Redcapter 无法生成正确，需要两个换行
      @text.gsub!("\n```","\n\n```")
      @text.gsub! "\r", ''
      convert_bbcode_img
    end

    def call
      html = MarkdownConverter.convert @text
      html.rstrip!
      html
    end

    def convert_bbcode_img
      @text.gsub!(/\[img\](.+?)\[\/img\]/i) {"![#{image_alt $1}](#{$1})"}
    end

    def image_alt(src)
      File.basename(src, '.*').capitalize
    end
  end

  class LinkMentionFloorFilter < HTML::Pipeline::Filter
    # convert '#N楼' to link
    def call
      doc.search("text()").each do |node|
        content = node.to_html
        next if has_ancestor?(node, %w(pre code))
        next if not content.include?("#")
        html = link_mention_floor_filter(content)
        next if html.nil?
        node.replace(html)
      end
      doc
    end

    def link_mention_floor_filter(html)
      html.gsub!(/#(\d+)([楼樓Ff])/) {
        %(<a href="#reply#{$1}" class="at_floor" data-floor="#{$1}">##{$1}#{$2}</a>)
      }
    end
  end

  class EmojiFilter < HTML::Pipeline::EmojiFilter
    def emoji_image_filter(text)
      return text unless text.include?(':')
      text.gsub(/:(\S+):/) do |emoji|
        emoji_code = emoji #.gsub("|", "_")
        emoji      = emoji_code.gsub(":", "")

        if MdEmoji::EMOJI.include?(emoji)
          file_name    = "#{emoji.gsub('+', 'plus')}.png"

          %{<img src="#{Setting.upload_url}/assets/emojis/#{file_name}" class="emoji" } +
          %{title="#{emoji_code}" alt="" />}
        else
          emoji_code
        end
      end
    end
  end

end

class MarkdownTopicConverter

  def self.format(raw)
    text = raw.clone
    return '' if text.blank?

    context = {
      :asset_root => "#{Setting.upload_url}/assets"
    }

    pipeline = HTML::Pipeline.new [
      PipelineFilters::MarkdownFilter,
      HTML::Pipeline::MentionFilter,
      PipelineFilters::EmojiFilter,
      PipelineFilters::LinkMentionFloorFilter
    ], context

    result = pipeline.call text
    return result[:output].to_s

  rescue => e
    puts "\n ERROR: MarkdownTopicConverter.format: #{e}"
    return text
  end

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
