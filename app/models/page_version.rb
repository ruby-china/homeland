class PageVersion < ApplicationRecord
  include MarkdownBody

  belongs_to :user
  belongs_to :page
end
