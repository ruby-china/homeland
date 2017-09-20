class SiteNode < ApplicationRecord
  second_level_cache version: 1, expires_in: 1.week

  has_many :sites

  validates :name, presence: true, uniqueness: true

  after_save :update_cache_version
  after_destroy :update_cache_version

  def update_cache_version
    # 记录节点变更时间，用于清除缓存
    CacheVersion.sites_updated_at = Time.now.to_i
  end
end
