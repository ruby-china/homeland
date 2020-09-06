# frozen_string_literal: true
class Column < ApplicationRecord
  include SoftDelete, MarkdownBody, Searchable

  second_level_cache expires_in: 2.weeks

  mount_uploader :cover, PhotoUploader
  validates :cover, :name, :slug, presence: true
  validates :name, uniqueness: { scope: %i[user_id], message: "专栏名重复"  }

  SLUG_FORMAT              = 'A-Za-z0-9\-\_\.'
  ALLOW_SLUG_FORMAT_REGEXP = /\A[#{SLUG_FORMAT}]+\z/
  validates :slug, format: { with: ALLOW_SLUG_FORMAT_REGEXP, message: "只允许数字、大小写字母、中横线、下划线" },
            length: { in: 4..30 },
            presence: true,
            uniqueness: { case_sensitive: false }

  scope :hot, -> { order(followers_count: :desc) }
  scope :banned, -> { order(unseal_time: :asc) }
  scope :global_block_columns, -> { where("columns.unseal_time IS NOT NULL").where("columns.unseal_time > :current_time", { current_time: Time.current }) }

  belongs_to :user, counter_cache: true, optional: true
  has_many :comments, dependent: :destroy
  has_many :articles, dependent: :destroy

  validate do
    if self.new_record?
      if self.user && self.user.columns.length >= Setting.column_max_count.to_i
        errors.add(:base, "你已经有很多专栏啦！")
      end
    end
  end

  def self.find_by_slug(slug)
    return nil unless slug.match? ALLOW_SLUG_FORMAT_REGEXP
    fetch_by_uniq_keys(slug: slug) || where("lower(slug) = ?", slug.downcase).take
  end

  def active
    unseal_time == nil or Time.now > unseal_time
  end

  def to_param
    slug
  end
end
