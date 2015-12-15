class Node
  include Mongoid::Document
  include Mongoid::Timestamps
  include Mongoid::BaseModel

  field :name
  field :summary
  field :sort, type: Integer, default: 0
  field :topics_count, type: Integer, default: 0

  delegate :name, to: :section, prefix: true, allow_nil: true

  has_many :topics
  belongs_to :section

  index section_id: 1

  validates :name, :summary, :section, presence: true
  validates :name, uniqueness: true

  has_and_belongs_to_many :followers, class_name: 'User', inverse_of: :following_nodes

  scope :hots, -> { desc(:topics_count) }
  scope :sorted, -> { desc(:sort) }

  after_save :update_cache_version
  after_destroy :update_cache_version

  def update_cache_version
    # 记录节点变更时间，用于清除缓存
    CacheVersion.section_node_updated_at = Time.now
  end

  # 招聘节点编号
  def self.jobs_id
    9
  end

  # NoPoint 节点编号
  def self.no_point_id
    61
  end

  # Markdown 转换过后的 HTML
  def summary_html
    Rails.cache.fetch("#{cache_key}/summary_html") do
      MarkdownConverter.convert(summary)
    end
  end

  # 是否为 jobs 节点
  def jobs?
    id == self.class.jobs_id
  end

  def self.new_topic_dropdowns
    return [] if SiteConfig.new_topic_dropdown_node_ids.blank?
    node_ids = SiteConfig.new_topic_dropdown_node_ids.split(',').uniq.take(5)
    where(:_id.in => node_ids)
  end
end
