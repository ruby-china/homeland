class Node < ApplicationRecord
  has_many :topics

  validates :name, presence: true
  validates :name, uniqueness: true

  scope :hots, -> { order(topics_count: :desc) }
  scope :sorted, -> { order(sort: :desc) }

  def self.name_options
    self.all.collect { |node| [node.name, node.id] }
  end

  def self.find_builtin_node(id, name)
    node = find_by_id(id)
    return node if node
    create(id: id, name: name)
  end

  def collapse_summary?
    @collapse_summary ||= summary_html.scan(/<p>|<ul>/).size > 2
  end

  def summary_html
    Rails.cache.fetch("#{cache_key_with_version}/summary_html") do
      Homeland::Markdown.call(summary || "")
    end
  end
end
