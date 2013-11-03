# coding: utf-8
require 'redcarpet'

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
