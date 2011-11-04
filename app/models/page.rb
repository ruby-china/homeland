# coding: utf-8
# 单页的文档页面
# 采用 Markdown 编写
require 'rdiscount'
class Page
  include Mongoid::Document
  include Mongoid::Timestamps  
  include Mongoid::BaseModel
  include Mongoid::SoftDelete
  
  # 页面地址
  field :slug
  field :title
  # 原始 Markdown 内容
  field :body
  # Markdown 格式化后的 html
  field :body_html
  field :editor_ids, :type => Array, :default => []
  field :locked, :type => Boolean, :default => false
  
  index :slug
  
  attr_accessor :user_id
  attr_protected :body_html, :locked, :editors
  validates_presence_of :slug, :title, :body, :user_id
  validates_uniqueness_of :slug
  
  before_save :markdown_for_body_html
  def markdown_for_body_html
    md = RDiscount.new(self.body)
    self.body_html = md.to_html
    md = nil
  rescue => e
    Rails.logger.error("markdown_for_body_html failed: #{e}")
  end
  
  before_save :append_editor
  def append_editor
    if not self.editor_ids.include?(self.user_id.to_i)
      self.editor_ids << self.user_id.to_i
    end
  end
  
  def editors
    User.where(:_id.in => self.editor_ids)
  end
  
  def self.find_by_slug(slug)
    where(:slug => slug).first
  end
end
