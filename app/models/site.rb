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
  field :favicon

  belongs_to :site_node
  counter_cache :name => :site_node, :inverse_of => :sites
  belongs_to :user

  validates_presence_of :url, :name, :site_node_id
  
  index :url

  before_validation :fix_urls, :check_uniq
  def fix_urls
    if self.favicon.blank?
      self.favicon = self.favicon_url
    else
      if self.favicon.match(/:\/\//).blank?
        self.favicon = "http://#{self.favicon}"
      end
    end

    if !self.url.blank?
      url = self.url.gsub(/http[s]{0,1}:\/\//,'').split('/').join("/")
      self.url = "http://#{url}"
    end
  end
  
  def check_uniq
    if Site.unscoped.or(:url => url).count > 0
      self.errors.add(:url,"已经提交过了。")
      return false
    end
  end

  def favicon_url
    return "" if self.url.blank?
    domain = self.url.gsub("http://","")
    "http://www.google.com/profiles/c/favicons?domain=#{domain}"
  end
end
