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
  field :editors, :type => Array
  field :locked, :type => Boolean
  
  attr_protected :body_html, :locked, :editors
  validates_presence_of :slug, :title, :body
  validates_uniqueness_of :slug
end
