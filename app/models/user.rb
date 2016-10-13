require 'digest/md5'

class User < ApplicationRecord
  include Redis::Search
  include Searchable
  include OmniauthCallbacks
  include Blockable
  include Likeable
  include Followable
  include TopicRead
  include TopicFavorate
  include GithubRepository
  include UserCallbacks

  acts_as_cached version: 4, expires_in: 1.week

  LOGIN_FORMAT = /[A-Za-z0-9\-\_\.]/
  ALLOW_LOGIN_CHARS_REGEXP = /\A#{LOGIN_FORMAT}+\z/

  devise :database_authenticatable, :registerable, :recoverable, :lockable,
         :rememberable, :trackable, :validatable, :omniauthable

  redis_search title_field: :login,
               alias_field: :name,
               score_field: :index_score,
               ext_fields: [:large_avatar_url, :name]

  mount_uploader :avatar, AvatarUploader

  has_many :topics, dependent: :destroy
  has_many :notes
  has_many :replies, dependent: :destroy
  has_many :authorizations, dependent: :destroy
  has_many :notifications, dependent: :destroy
  has_many :photos
  has_many :oauth_applications, class_name: 'Doorkeeper::Application', as: :owner
  has_many :devices
  has_many :team_users
  has_many :teams, through: :team_users

  attr_accessor :password_confirmation

  ACCESSABLE_ATTRS = [:name, :email_public, :location, :company, :bio, :website, :github, :twitter,
                      :tagline, :avatar, :by, :current_password, :password, :password_confirmation,
                      :_rucaptcha]

  enum state: { deleted: -1, normal: 1, blocked: 2 }

  validates :login, format: { with: ALLOW_LOGIN_CHARS_REGEXP, message: '只允许数字、大小写字母、中横线、下划线' },
                    length: { in: 2..20 },
                    presence: true,
                    uniqueness: { case_sensitive: false }

  validates :name, length: { maximum: 20 }

  scope :hot, -> { order(replies_count: :desc).order(topics_count: :desc) }
  scope :without_team, -> { where(type: nil) }
  scope :fields_for_list, -> {
    select(:type, :id, :name, :login, :email, :email_md5, :email_public, :avatar, :verified, :state,
           :tagline, :github, :website, :location, :location_id, :twitter, :co, :team_users_count)
  }

  def self.find_by_email(email)
    fetch_by_uniq_keys(email: email)
  end

  def self.find_by_login!(slug)
    find_by_login(slug) || raise(ActiveRecord::RecordNotFound.new(slug: slug))
  end

  def self.find_by_login(slug)
    return nil unless slug =~ ALLOW_LOGIN_CHARS_REGEXP
    fetch_by_uniq_keys(login: slug) || where('lower(login) = ?', slug.downcase).take
  end

  def self.find_by_login_or_email(login_or_email)
    login_or_email = login_or_email.downcase
    find_by_login(login_or_email) || find_by_email(login_or_email)
  end

  def self.find_for_database_authentication(warden_conditions)
    conditions = warden_conditions.dup
    login = conditions.delete(:login)
    login.downcase!
    where(conditions.to_h).where(['lower(login) = :value OR lower(email) = :value', { value: login }]).first
  end

  def self.current
    Thread.current[:current_user]
  end

  def self.current=(user)
    Thread.current[:current_user] = user
  end

  def to_param
    login
  end

  def user_type
    (self[:type] || 'User').underscore.to_sym
  end

  def organization?
    self.user_type == :team
  end

  def email=(val)
    self.email_md5 = Digest::MD5.hexdigest(val || '')
    self[:email] = val
  end

  def password_required?
    (authorizations.empty? || !password.blank?) && super
  end

  def profile_url
    "/#{login}"
  end

  def github_url
    return '' if github.blank?
    "https://github.com/#{github.split('/').last}"
  end

  def website_url
    return '' if website.blank?
    website[%r{^https?://}] ? website : "http://#{website}"
  end

  def twitter_url
    return '' if twitter.blank?
    "https://twitter.com/#{twitter}"
  end

  def fullname
    return login if name.blank?
    "#{login} (#{name})"
  end

  # 是否是管理员
  def admin?
    Setting.admin_emails.include?(email)
  end

  # 是否有 Wiki 维护权限
  def wiki_editor?
    self.admin? || verified == true
  end

  # 回帖大于 150 的才有酷站的发布权限
  def site_editor?
    self.admin? || replies_count >= 100
  end

  # 是否能发帖
  def newbie?
    return false if verified? || hr?
    created_at > 1.week.ago
  end

  def roles?(role)
    case role
    when :admin then admin?
    when :wiki_editor then wiki_editor?
    when :site_editor then site_editor?
    when :member then self.normal?
    else false
    end
  end

  # 用户的账号类型
  def level
    if admin?
      return 'admin'
    elsif verified?
      return 'vip'
    elsif hr?
      return 'hr'
    elsif blocked?
      return 'blocked'
    elsif newbie?
      return 'newbie'
    else
      return 'normal'
    end
  end

  def level_name
    I18n.t("common.#{level}_user")
  end

  def update_with_password(params = {})
    if !params[:current_password].blank? || !params[:password].blank? || !params[:password_confirmation].blank?
      super
    else
      params.delete(:current_password)
      update_without_password(params)
    end
  end

  # Override Devise to send mails with async
  def send_devise_notification(notification, *args)
    devise_mailer.send(notification, self, *args).deliver_later
  end

  def bind?(provider)
    authorizations.collect(&:provider).include?(provider)
  end

  def bind_service(response)
    provider = response['provider']
    uid = response['uid'].to_s
    authorizations.create(provider: provider, uid: uid)
  end

  # 软删除
  def soft_delete
    self.state = 'deleted'
    save(validate: false)
  end

  def letter_avatar_url(size)
    path = LetterAvatar.generate(self.login, size).sub('public/', '/')

    "#{Setting.protocol}://#{Setting.domain}#{path}"
  end

  def large_avatar_url
    if self[:avatar].present?
      self.avatar.url(:lg)
    else
      self.letter_avatar_url(192)
    end
  end

  def avatar?
    self[:avatar].present?
  end

  # @example.com 的可以修改邮件地址
  def email_locked?
    self.email.exclude?('@example.com')
  end

  def calendar_data
    Rails.cache.fetch(['user', self.id, 'calendar_data', Date.today, 'by-months']) do
      calendar_data_without_cache
    end
  end

  def calendar_data_without_cache
    date_from = 12.months.ago.beginning_of_month.to_date
    replies = self.replies.where('created_at > ?', date_from)
                  .group("date(created_at AT TIME ZONE 'CST')")
                  .select("date(created_at AT TIME ZONE 'CST') AS date, count(id) AS total_amount").all

    replies.each_with_object({}) do |reply, timestamps|
      timestamps[reply['date'].to_time.to_i.to_s] = reply['total_amount']
    end
  end

  def team_collection
    return @team_collection if defined? @team_collection
    teams = self.admin? ? Team.all : self.teams
    @team_collection = teams.collect { |t| [t.name, t.id] }
  end

  # for Searchable
  def index_score
    0
  end

  # for Searchable
  def as_indexed_json(_options = {})
    as_json(only: [:login, :name])
  end
end
