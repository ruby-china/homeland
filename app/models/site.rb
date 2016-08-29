class Site < ApplicationRecord
  include SoftDelete

  belongs_to :site_node
  belongs_to :user

  validates :url, :name, :site_node_id, presence: true
  validates :url, uniqueness: true

  after_save :update_cache_version
  after_destroy :update_cache_version
  def update_cache_version
    # 记录节点变更时间，用于清除缓存
    CacheVersion.sites_updated_at = Time.now.to_i
  end

  before_validation :fix_urls
  def fix_urls
    unless url.blank?
      url = self.url.gsub(%r{http[s]{0,1}://}, '').split('/').join('/')
      self.url = "http://#{url}"
    end
  end

  def favicon_url
    return '' if url.blank?
    domain = url.gsub('http://', '')
    "https://favicon.b0.upaiyun.com/ip2/#{domain}.ico"
  end
end
