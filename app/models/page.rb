# 单页的文档页面
# 采用 Markdown 编写
require 'redcarpet'
class Page
  include Mongoid::Document
  include Mongoid::Timestamps
  include Mongoid::BaseModel
  include Mongoid::SoftDelete
  include Mongoid::MarkdownBody
  include Elasticsearch::Model
  include Elasticsearch::Model::Callbacks

  # 页面地址
  field :slug
  field :title
  # 原始 Markdown 内容
  field :body
  # Markdown 格式化后的 html
  field :body_html
  field :editor_ids, type: Array, default: []
  field :locked, type: Mongoid::Boolean, default: false
  field :comments_count, type: Integer, default: 0
  # 目前版本号
  field :version, type: Integer, default: 0

  index slug: 1

  has_many :versions, class_name: 'PageVersion'

  attr_accessor :user_id, :change_desc, :version_enable

  validates :slug, :title, :body, presence: true
  # 当需要记录版本时，如果是更新，那么要求填写 :change_desc
  validates :user_id, if: proc { |p| p.version_enable == true }, presence: true
  validates :change_desc, if: proc { |p| p.version_enable == true && !p.new_record? }, presence: true
  validates :slug, format: /\A[a-z0-9\-_]+\z/
  validates :slug, uniqueness: true

  mapping do
    indexes :title
    indexes :body
    indexes :slug
  end

  def as_indexed_json(options={})
    as_json(only: %w(slug title body))
  end

  before_save :append_editor
  def append_editor
    unless editor_ids.include?(user_id.to_i)
      editor_ids << user_id.to_i
    end
  end

  # 记录更新版本
  after_save :create_version
  def create_version
    # 只有当 version_enable 为 true 的时候才记录版本
    # 以免后台，以及其他的一些 update 时被误调用
    return true unless version_enable
    # 只有 body, title, slug 更改了才更新版本
    if self.body_changed? || self.title_changed? || self.slug_changed?
      inc(version: 1)
      PageVersion.create(user_id: user_id,
                         page_id: id,
                         desc: change_desc,
                         version: version,
                         body: body,
                         title: title,
                         slug: slug)
    end
  end

  def to_param
    slug
  end

  # 撤掉到指定版本
  def revert_version(version)
    page_version = PageVersion.where(page_id: id, version: version).first
    return false if page_version.blank?
    update_attributes(body: page_version.body,
                      title: page_version.title,
                      slug: page_version.slug)
  end

  def editors
    User.where(:_id.in => editor_ids)
  end

  def self.find_by_slug(slug)
    where(slug: slug).first
  end
end
