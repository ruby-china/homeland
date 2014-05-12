# coding: utf-8
class SiteNode
  include Mongoid::Document
  include Mongoid::BaseModel

  field :name
  field :sort, type: Integer, default: 0
  has_many :sites

  validates_presence_of :name
  validates_uniqueness_of :name

  after_save :update_cache_version
  after_destroy :update_cache_version
  def update_cache_version
    # 记录节点变更时间，用于清除缓存
    CacheVersion.sites_updated_at = Time.now.to_i
  end
end
