# coding: utf-8
module Mongoid
  module MarkdownBody
    extend ActiveSupport::Concern

    included do
      before_save :markdown_body
      scope :without_body, without(:body)
    end

    private
      def markdown_body
        self.body_html = MarkdownTopicConverter.format(self.body) if self.body_changed?
      end
  end
end