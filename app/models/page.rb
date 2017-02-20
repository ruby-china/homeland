class Page < ApplicationRecord
  include MarkdownBody
  include Searchable

  counter :hits, default: 0

  second_level_cache expires_in: 2.weeks

  has_many :versions, class_name: 'PageVersion'

  attr_accessor :user_id, :change_desc, :version_enable

  validates :slug, :title, :body, presence: true
  # 当需要记录版本时，如果是更新，那么要求填写 :change_desc
  validates :user_id, if: proc { |p| p.version_enable == true }, presence: true
  validates :change_desc, if: proc { |p| p.version_enable == true && !p.new_record? }, presence: true
  validates :slug, format: /\A[a-z0-9\-_]+\z/
  validates :slug, uniqueness: true

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
      update_column(:version, self.version + 1)
      PageVersion.create(user_id: user_id,
                         page_id: id,
                         desc: change_desc || '',
                         version: version,
                         body: body,
                         title: title,
                         slug: slug)
    end
  end

  def as_indexed_json(_options = {})
    as_json(only: [:slug, :title, :body])
  end

  def indexed_changed?
    slug_changed? || title_changed? || body_changed?
  end

  def to_param
    slug
  end

  # 撤掉到指定版本
  def revert_version(version)
    page_version = PageVersion.where(page_id: id, version: version).first
    return false if page_version.blank?
    update(body: page_version.body,
           title: page_version.title,
           slug: page_version.slug)
  end

  def editors
    User.where(id: editor_ids)
  end

  def self.find_by_slug(slug)
    fetch_by_uniq_keys(slug: slug)
  end
end
