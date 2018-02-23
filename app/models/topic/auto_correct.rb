# frozen_string_literal: true

require "auto-space"

CORRECT_CHARS = [
  ["［", "["],
  ["］", "]"],
  ["【", "["],
  ["】", "]"],
  ["（", "("],
  ["）", ")"]
]

class Topic
  module AutoCorrect
    extend ActiveSupport::Concern

    included do
      before_save :auto_correct_title
    end

    def auto_correct_title
      return if title.blank?
      title.dup
      CORRECT_CHARS.each do |chars|
        title.gsub!(chars[0], chars[1])
      end
      title.auto_space!
    end
  end
end
