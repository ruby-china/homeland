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
  validates_uniqueness_of :url
  
  before_save :fix_urls
  def fix_urls
    if self.favicon.blank?
      self.favicon = self.favicon_url
    else
      if self.favicon.match(/:\/\//).blank?
        self.favicon = "http://#{self.favicon}"
      end
    end
    
    if !self.url.blank?
      if self.url.match(/:\/\//).blank?
        self.url = "http://#{self.url}"
      end
    end
  end
  
  def favicon_url
    return "" if self.url.blank?
    domain = self.url.gsub("http://","")
    "http://www.google.com/profiles/c/favicons?domain=#{domain}"
  end
end
