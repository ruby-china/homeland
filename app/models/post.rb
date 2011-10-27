# coding: utf-8
class Post
  include Mongoid::Document
  include Mongoid::Timestamps
  include Mongoid::SoftDelete
  include Redis::Search
  include Redis::Objects
  
  STATE = {
    :draft => 0,
    :normal => 1
  }
  
  field :title, :type => String
  field :body, :type => String
  field :state, :type => Integer, :default => STATE[:draft]
  field :tags, :type => Array, :default => []
  # 来源名称
  field :source
  # 来源地址
  field :source_url
  belongs_to :user
  
  counter :hits, :default => 0
  
  attr_protected :state, :user_id
  attr_accessor :tag_list
  
  validates_presence_of :title, :body, :tag_list
  
  scope :normal, where(:state => STATE[:normal])
  scope :recent, desc(:_id)
  
  before_save :split_tags
  def split_tags
    if !self.tag_list.blank? and self.tags.blank?
      self.tags = self.tag_list.split(/,|，/).collect { |tag| tag.strip }.uniq
    end
  end
  
  # 给下拉框用
  def self.state_collection
    STATE.collect { |s| [s[0], s[1]]}
  end
  
  def state_s
    case self.state
    when 0 then "<span class='label important'>草稿</span>"
    else
      "<span class='label success'>已审核</span>"
    end
  end
end
