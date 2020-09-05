# frozen_string_literal: true

require "digest/md5"

class User < ApplicationRecord
  include Searchable
  include User::Roles, User::Blockable, User::Likeable, User::Followable, User::TopicActions,
          User::GitHubRepository, User::ProfileFields, User::RewardFields, User::Omniauthable,
          User::Avatar

  second_level_cache version: 4, expires_in: 2.weeks

  ANONYMOUS_ID = 12
  LOGIN_FORMAT              = 'A-Za-z0-9\-\_\.'
  ALLOW_LOGIN_FORMAT_REGEXP = /\A[#{LOGIN_FORMAT}]+\z/

  ACCESSABLE_ATTRS = %i[name email_public location company bio website github twitter tagline avatar by
                        current_password password password_confirmation _rucaptcha]

  devise :database_authenticatable, :registerable, :recoverable, :lockable,
         :rememberable, :trackable, :validatable, :omniauthable

  has_one :profile, dependent: :destroy

  has_many :topics, dependent: :destroy
  has_many :replies, dependent: :destroy
  has_many :authorizations, dependent: :destroy
  has_many :notifications, dependent: :destroy
  has_many :photos
  has_many :oauth_applications, class_name: "Doorkeeper::Application", as: :owner
  has_many :devices
  has_many :team_users
  has_many :teams, through: :team_users
  has_one :sso, class_name: "UserSSO", dependent: :destroy

  attr_accessor :password_confirmation

  validates :login, format: { with: ALLOW_LOGIN_FORMAT_REGEXP, message: "只允许数字、大小写字母、中横线、下划线" },
                    length: { in: 2..20 },
                    presence: true,
                    uniqueness: { case_sensitive: false }
  validates :name, length: { maximum: 20 }

  after_commit :send_welcome_mail, on: :create

  scope :hot, -> { order(replies_count: :desc).order(topics_count: :desc) }
  scope :without_team, -> { where(type: nil) }
  scope :fields_for_list, lambda {
    select(:type, :id, :name, :login, :email, :email_md5, :email_public,
           :avatar, :state, :tagline, :github, :website, :location,
           :location_id, :twitter, :team_users_count, :created_at, :updated_at)
  }

  def self.find_by_email(email)
    fetch_by_uniq_keys(email: email)
  end

  def self.find_by_login!(slug)
    find_by_login(slug) || raise(ActiveRecord::RecordNotFound.new(slug: slug))
  end

  def self.find_by_login(slug)
    return nil unless slug.match? ALLOW_LOGIN_FORMAT_REGEXP
    fetch_by_uniq_keys(login: slug) || where("lower(login) = ?", slug.downcase).take
  end

  def self.find_by_login_or_email(login_or_email)
    login_or_email = login_or_email.downcase
    find_by_login(login_or_email) || find_by_email(login_or_email)
  end

  def self.find_for_database_authentication(warden_conditions)
    conditions = warden_conditions.dup
    login = conditions.delete(:login).downcase
    where(conditions.to_h).where(["(lower(login) = :value OR lower(email) = :value) and state != -1", { value: login }]).first
  end

  def self.admin_users
    User.where(:email => Setting.admin_email_list).to_a
  end

  def self.search(term, user: nil, limit: 30)
    following = []
    term = term.to_s + "%"
    users = User.where("login ilike ? or name ilike ?", term, term).order("replies_count desc").limit(limit).to_a
    if user
      following = user.follow_users.where("login ilike ? or name ilike ?", term, term).to_a
    end
    users.unshift(*Array(following))
    users.uniq!
    users.compact!

    users.first(limit)
  end

  def to_param
    login
  end

  def user_type
    (self[:type] || "User").underscore.to_sym
  end

  def organization?
    self.user_type == :team
  end

  def email=(val)
    self.email_md5 = Digest::MD5.hexdigest(val || "")
    self[:email] = val
  end

  def password_required?
    (authorizations.empty? || !password.blank?) && super
  end

  # Override Devise to send mails with async
  def send_devise_notification(notification, *args)
    devise_mailer.send(notification, self, *args).deliver_later
  end

  def send_welcome_mail
    UserMailer.welcome(id).deliver_later
  end

  def profile_url
    "/#{login}"
  end

  def github_url
    return "" if github.blank?
    "https://github.com/#{github.split('/').last}"
  end

  def website_url
    return "" if website.blank?
    website[%r{^https?://}] ? website : "http://#{website}"
  end

  def twitter_url
    return "" if twitter.blank?
    "https://twitter.com/#{twitter}"
  end

  def fullname
    return login if name.blank?
    "#{login} (#{name})"
  end

  # 软删除
  def soft_delete
    self.state = "deleted"
    save(validate: false)
  end

  # @example.com 的可以修改邮件地址
  def email_locked?
    self.email.exclude?("@example.com")
  end

  def calendar_data
    Rails.cache.fetch(["user", self.id, "calendar_data", Date.today, "by-months"]) do
      calendar_data_without_cache
    end
  end

  def calendar_data_without_cache
    date_from = 12.months.ago.beginning_of_month.to_date
    replies = self.replies.where("created_at > ?", date_from)
                  .group("date(created_at AT TIME ZONE 'CST')")
                  .select("date(created_at AT TIME ZONE 'CST') AS date, count(id) AS total_amount").all

    replies.each_with_object({}) do |reply, timestamps|
      timestamps[reply["date"].to_time.to_i.to_s] = reply["total_amount"]
    end
  end

  def team_options
    return @team_options if defined? @team_options
    teams = self.admin? ? Team.all : self.teams
    @team_options = teams.collect { |t| [t.name, t.id] }
  end

  # for Searchable
  def as_indexed_json
    {
      title: fullname,
    }.as_json
  end

  def indexed_changed?
    %i[login name].each do |key|
      return true if saved_change_to_attribute?(key)
    end
    false
  end
end
