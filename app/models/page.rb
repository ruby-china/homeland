# coding: utf-8
# 单页的文档页面
# 采用 Markdown 编写
class Page
  include Mongoid::Document
  include Mongoid::Timestamps  
  include Mongoid::SoftDelete
  include Mongoid::Versioning
  
  # 页面地址
  field :slug
  field :title
  # 原始 Markdown 内容
  field :body
  # Markdown 格式化后的 html
  field :body_html
  field :editors, :type => Array, :default => []
  field :locked, :type => Boolean, :default => false
  
  attr_accessor :user_id
  attr_protected :body_html, :locked, :editors
  validates_presence_of :slug, :title, :body, :user_id
  validates_uniqueness_of :slug
  
  before_save :markdown_for_body_html
  def markdown_for_body_html
    self.body_html = BlueCloth.new(str).to_html
  rescue => e
    Rails.logger.error("markdown_for_body_html failed: #{e}")
  end
  
  before_save :append_editor
  def append_editor
    if not self.editors.include?(self.user_id.to_i)
      self.editors << self.user_id.to_i
    end
  end
end
