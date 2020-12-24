# frozen_string_literal: true

class Node < ApplicationRecord
  second_level_cache expires_in: 2.weeks

  has_many :topics

  validates :name, presence: true
  validates :name, uniqueness: true

  scope :hots, -> { order(topics_count: :desc) }
  scope :sorted, -> { order(sort: :desc) }

  form_select :name

  def self.find_builtin_node(id, name)
    node = self.find_by_id(id)
    return node if node
    self.create(id: id, name: name)
  end

  # 是否 Summary 过多需要折叠
  def collapse_summary?
    @collapse_summary ||= self.summary_html.scan(/\<p\>|\<ul\>/).size > 2
  end

  # Markdown 转换过后的 HTML
  def summary_html
    Rails.cache.fetch("#{cache_key_with_version}/summary_html") do
      Homeland::Markdown.call(summary || "")
    end
  end
end
