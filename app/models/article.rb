# frozen_string_literal: true

class Article < Topic
  belongs_to :column, inverse_of: :articles, counter_cache: true
end
