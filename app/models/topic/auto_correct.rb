# frozen_string_literal: true

class Topic
  module AutoCorrect
    extend ActiveSupport::Concern

    included do
      before_save :auto_correct_title
    end

    private

    def auto_correct_title
      return if title.blank?
      self.title = ::AutoCorrect.format(title)
    end
  end
end
