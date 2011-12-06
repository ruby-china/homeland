# coding: utf-8  
class Node
  include Mongoid::Document
  include Mongoid::Timestamps
  include Mongoid::BaseModel

  field :name
  field :summary
  field :sort, :type => Integer, :default => 0
  field :topics_count, :type => Integer, :default => 0
  
  has_many :topics
  belongs_to :section
  
  index :section_id
  
  validates_presence_of :name, :summary, :section
  validates_uniqueness_of :name
  
  has_and_belongs_to_many :followers, :class_name => 'User', :inverse_of => :following_nodes

  scope :hots, desc(:topics_count)
  scope :sorted, desc(:sort)
  
  after_save do
    # 记录节点变更时间，用于清除缓存
    CacheVersion.section_node_updated_at = Time.now
  end
  
  # 热门节电给 select 用的
  def self.hot_node_collection
    Rails.cache.fetch("node:hot_node_collection:#{CacheVersion.section_node_updated_at}") do
      Node.hots.collect { |n| [n.name,n.id] }
    end
  end
end
