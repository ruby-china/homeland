# coding: utf-8
class Site
  include Mongoid::Document
  include Mongoid::BaseModel
  include Mongoid::Timestamps
  include Mongoid::SoftDelete
  include Mongoid::CounterCache

  field :name
  field :url
  field :desc

  belongs_to :site_node
  counter_cache :name => :site_node, :inverse_of => :sites
  belongs_to :user

  validates_presence_of :url, :name, :site_node_id

  index :url => 1
  index :site_node_id => 1

  after_save :update_cache_version
  after_destroy :update_cache_version
  def update_cache_version
    # 记录节点变更时间，用于清除缓存
    CacheVersion.sites_updated_at = Time.now.to_i
  end

  before_validation :fix_urls, :check_uniq
  def fix_urls
    if !self.url.blank?
      url = self.url.gsub(/http[s]{0,1}:\/\//,'').split('/').join("/")
      self.url = "http://#{url}"
    end
  end

  def check_uniq
    if Site.unscoped.where(:url => url, :_id.ne => self.id).count > 0
      self.errors.add(:url,"已经提交过了。")
    end
  end

  def favicon_url
    return "" if self.url.blank?
    domain = self.url.gsub("http://","")
    "http://www.google.com/profiles/c/favicons?domain=#{domain}"
  end
end
