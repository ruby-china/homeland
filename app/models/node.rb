# frozen_string_literal: true

class Node < ApplicationRecord
  second_level_cache expires_in: 2.weeks

  delegate :name, to: :section, prefix: true, allow_nil: true

  has_many :topics
  belongs_to :section, optional: true

  validates :name, :summary, :section, presence: true
  validates :name, uniqueness: true

  scope :hots, -> { order(topics_count: :desc) }
  scope :sorted, -> { order(sort: :desc) }

  form_select :name

  after_save :update_cache_version
  after_destroy :update_cache_version

  def self.find_builtin_node(id, name)
    node = self.find_by_id(id)
    return node if node
    self.create(id: id, name: name, summary: name, section: Section.default)
  end

  # 是否 Summary 过多需要折叠
  def collapse_summary?
    @collapse_summary ||= self.summary_html.scan(/\<p\>|\<ul\>/).size > 2
  end

  def update_cache_version
    # 记录节点变更时间，用于清除缓存
    CacheVersion.section_node_updated_at = Time.now
  end

  # Markdown 转换过后的 HTML
  def summary_html
    Rails.cache.fetch("#{cache_key_with_version}/summary_html") do
      Homeland::Markdown.call(summary)
    end
  end

  def nickname_node?
    name.index("匿名").present?
  end
end
