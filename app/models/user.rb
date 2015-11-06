require 'securerandom'
require 'digest/md5'
require 'open-uri'

class User
  include Mongoid::Document
  include Mongoid::Timestamps
  include Mongoid::BaseModel
  include Redis::Objects
  extend OmniauthCallbacks

  ALLOW_LOGIN_CHARS_REGEXP = /\A\w+\z/

  devise :database_authenticatable, :registerable, :recoverable,
         :rememberable, :trackable, :validatable, :omniauthable, :async

  field :email, type: String, default: ''
  # Email 的 md5 值，用于 Gravatar 头像
  field :email_md5
  # Email 是否公开
  field :email_public, type: Mongoid::Boolean
  field :encrypted_password, type: String, default: ''

  ## Recoverable
  field :reset_password_token,   type: String
  field :reset_password_sent_at, type: Time

  ## Rememberable
  field :remember_created_at, type: Time

  ## Trackable
  field :sign_in_count,      type: Integer, default: 0
  field :current_sign_in_at, type: Time
  field :last_sign_in_at,    type: Time
  field :current_sign_in_ip, type: String
  field :last_sign_in_ip,    type: String

  field :login
  field :name
  field :location
  field :location_id, type: Integer
  field :bio
  field :website
  field :company
  field :github
  field :twitter
  # 是否信任用户
  field :verified, type: Mongoid::Boolean, default: false
  # 是否是 HR
  field :hr, type: Mongoid::Boolean, default: false
  field :state, type: Integer, default: 1
  field :tagline
  field :topics_count, type: Integer, default: 0
  field :replies_count, type: Integer, default: 0
  # 用户密钥，用于客户端验证
  field :private_token
  field :favorite_topic_ids, type: Array, default: []
  # 屏蔽的节点
  field :blocked_node_ids, type: Array, default: []
  # 屏蔽的用户
  field :blocked_user_ids, type: Array, default: []

  mount_uploader :avatar, AvatarUploader

  index login: 1
  index email: 1
  index location: 1
  index replies_count: -1, topics_count: -1
  index({ private_token: 1 }, sparse: true)

  has_many :topics, dependent: :destroy
  has_many :notes
  has_many :replies, dependent: :destroy
  embeds_many :authorizations
  has_many :notifications, class_name: 'Notification::Base', dependent: :delete
  has_many :photos
  has_many :oauth_applications, class_name: 'Doorkeeper::Application', as: :owner

  def read_notifications(notifications)
    unread_ids = notifications.find_all { |notification| !notification.read? }.map(&:_id)
    if unread_ids.any?
      Notification::Base.where(user_id: id,
                               :_id.in => unread_ids,
                               read: false).update_all(read: true, updated_at: Time.now)
    end
  end

  attr_accessor :password_confirmation

  ACCESSABLE_ATTRS = [:name, :email_public, :location, :company, :bio, :website, :github, :twitter,
                      :tagline, :avatar, :by, :current_password, :password, :password_confirmation,
                      :_rucaptcha]

  STATE = {
    # 软删除
    deleted: -1,
    # 正常
    normal: 1,
    # 屏蔽
    blocked: 2
  }

  validates :login, format: { with: ALLOW_LOGIN_CHARS_REGEXP, message: '只允许数字、大小写字母和下划线' },
                    length: { in: 3..20 }, presence: true,
                    uniqueness: { case_sensitive: false }

  has_and_belongs_to_many :following, class_name: 'User', inverse_of: :followers
  has_and_belongs_to_many :followers, class_name: 'User', inverse_of: :following

  scope :hot, -> { desc(:replies_count, :topics_count) }
  scope :fields_for_list, lambda {
    only(:_id, :name, :login, :email, :email_md5, :email_public, :avatar, :verified, :state,
         :tagline, :github, :website, :location, :location_id, :twitter, :co)
  }

  def to_param
    login
  end

  def email=(val)
    self.email_md5 = Digest::MD5.hexdigest(val || '')
    self[:email] = val
  end

  def temp_access_token
    Rails.cache.fetch("user-#{id}-temp_access_token-#{Time.now.strftime('%Y%m%d')}") do
      SecureRandom.hex
    end
  end

  def self.find_for_database_authentication(conditions)
    login = conditions.delete(:login)
    where(login: /^#{login}$/i).first || where(email: /^#{login}$/i).first
  end

  def password_required?
    (authorizations.empty? || !password.blank?) && super
  end

  def github_url
    return '' if github.blank?
    "https://github.com/#{github.split('/').last}"
  end

  def twitter_url
    return '' if twitter.blank?
    "https://twitter.com/#{twitter}"
  end

  def google_profile_url
    return '' if email.blank? || !email.match(/gmail\.com/)
    "http://www.google.com/profiles/#{email.split('@').first}"
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
    return false if verified? or hr?
    created_at > 1.week.ago
  end

  def hr?
    hr == true
  end

  def verified?
    verified == true
  end

  def blocked?
    state == STATE[:blocked]
  end

  def deleted?
    state == STATE[:deleted]
  end

  def has_role?(role)
    case role
    when :admin then admin?
    when :wiki_editor then wiki_editor?
    when :site_editor then site_editor?
    when :member then state == STATE[:normal]
    else false
    end
  end

  # before_create :default_value_for_create
  # def default_value_for_create
  #   self.state = STATE[:normal]
  # end

  # 注册邮件提醒
  after_create :send_welcome_mail
  def send_welcome_mail
    UserMailer.welcome(id).deliver_later
  end

  # 保存用户所在城市
  before_save :store_location
  def store_location
    if self.location_changed?
      if !location.blank?
        old_location = Location.find_by_name(location_was)
        old_location.inc(users_count: -1) unless old_location.blank?
        location = Location.find_or_create_by_name(self.location)
        location.inc(users_count: 1)
        self.location_id = (location.blank? ? nil : location.id)
      else
        self.location_id = nil
      end
    end
  end

  def update_with_password(params = {})
    if !params[:current_password].blank? || !params[:password].blank? || !params[:password_confirmation].blank?
      super
    else
      params.delete(:current_password)
      update_without_password(params)
    end
  end

  def self.find_by_email(email)
    where(email: email).first
  end

  def self.find_login(slug)
    # FIXME: Regexp search in MongoDB is slow!!!
    fail Mongoid::Errors::DocumentNotFound.new(self, slug: slug) unless slug =~ ALLOW_LOGIN_CHARS_REGEXP
    where(login: /^#{slug}$/i).first || fail(Mongoid::Errors::DocumentNotFound.new(self, slug: slug))
  end

  def bind?(provider)
    authorizations.collect(&:provider).include?(provider)
  end

  def bind_service(response)
    provider = response['provider']
    uid = response['uid'].to_s
    authorizations.create(provider: provider, uid: uid)
  end

  # 是否读过 topic 的最近更新
  def topic_read?(topic)
    # 用 last_reply_id 作为 cache key ，以便不热门的数据自动被 Memcached 挤掉
    last_reply_id = topic.last_reply_id || -1
    Rails.cache.read("user:#{id}:topic_read:#{topic.id}") == last_reply_id
  end

  def filter_readed_topics(topics)
    t1 = Time.now
    return [] if topics.blank?
    cache_keys = topics.map { |t| "user:#{id}:topic_read:#{t.id}" }
    results = Rails.cache.read_multi(*cache_keys)
    ids = []
    topics.each do |topic|
      val = results["user:#{id}:topic_read:#{topic.id}"]
      if (val == (topic.last_reply_id || -1))
        ids << topic.id
      end
    end
    t2 = Time.now
    logger.info "  User filter_readed_topics (#{(t2 - t1) * 1000}ms)"
    ids
  end

  # 将 topic 的最后回复设置为已读
  def read_topic(topic)
    return if topic.blank?
    return if self.topic_read?(topic)

    notifications.unread.any_of({ mentionable_type: 'Topic', mentionable_id: topic.id },
                                { mentionable_type: 'Reply', :mentionable_id.in => topic.reply_ids },
                                :reply_id.in => topic.reply_ids).update_all(read: true)

    # 处理 last_reply_id 是空的情况
    last_reply_id = topic.last_reply_id || -1
    Rails.cache.write("user:#{id}:topic_read:#{topic.id}", last_reply_id)
  end

  # 收藏东西
  def like(likeable)
    return false if likeable.blank?
    return false if liked?(likeable)
    likeable.push(liked_user_ids: id)
    return false if likeable.likes_count == likeable.liked_user_ids.size
    likeable.inc(likes_count: 1)
    likeable.touch
  end

  # 取消收藏
  def unlike(likeable)
    return false if likeable.blank?
    return false unless liked?(likeable)
    likeable.pull(liked_user_ids: id)
    return false if likeable.likes_count == likeable.liked_user_ids.size
    likeable.inc(likes_count: -1)
    likeable.touch
  end

  # 是否喜欢过
  def liked?(likeable)
    likeable.liked_by_user?(self) || likeable.user_id == self.id
  end

  # 收藏话题
  def favorite_topic(topic_id)
    return false if topic_id.blank?
    topic_id = topic_id.to_i
    return false if favorited_topic?(topic_id)
    push(favorite_topic_ids: topic_id)
    true
  end

  # 取消对话题的收藏
  def unfavorite_topic(topic_id)
    return false if topic_id.blank?
    topic_id = topic_id.to_i
    pull(favorite_topic_ids: topic_id)
    true
  end

  # 是否收藏过话题
  def favorited_topic?(topic_id)
    favorite_topic_ids.include?(topic_id)
  end

  def favorite_topics_count
    favorite_topic_ids.size
  end

  # 软删除
  # 只是把用户信息修改了
  def soft_delete
    # assuming you have deleted_at column added already
    self.bio = ''
    self.website = ''
    self.github = ''
    self.tagline = ''
    self.location = ''
    self.authorizations = []
    self.state = STATE[:deleted]
    save(validate: false)
  end

  # GitHub 项目
  def github_repositories
    cache_key = github_repositories_cache_key
    items = Rails.cache.read(cache_key)
    if items.nil?
      GithubRepoFetcherJob.perform_later(id)
      items = []
    end
    items
  end

  def github_repositories_cache_key
    "github_repositories:#{github}+10+v4"
  end

  def self.fetch_github_repositories(user_id)
    user = User.find_by_id(user_id)
    return false if user.blank?

    github_login = user.github || user.login

    url = "https://api.github.com/users/#{github_login}/repos?type=owner&sort=pushed&client_id=#{Setting.github_token}&client_secret=#{Setting.github_secret}"
    begin
      json = Timeout.timeout(10) do
        open(url).read
      end
    rescue => e
      Rails.logger.error("GitHub Repositiory fetch Error: #{e}")
      items = []
      Rails.cache.write(user.github_repositories_cache_key, items, expires_in: 1.minutes)
      return false
    end

    items = JSON.parse(json)
    items = items.collect do |a1|
      {
        name: a1['name'],
        url: a1['html_url'],
        watchers: a1['watchers'],
        language: a1['language'],
        description: a1['description']
      }
    end
    items = items.sort { |a1, a2| a2[:watchers] <=> a1[:watchers] }.take(10)
    Rails.cache.write(user.github_repositories_cache_key, items, expires_in: 15.days)
    items
  end

  # 重新生成 Private Token
  def update_private_token
    random_key = "#{SecureRandom.hex(10)}:#{id}"
    update_attribute(:private_token, random_key)
  end

  def ensure_private_token!
    update_private_token if private_token.blank?
  end

  def block_node(node_id)
    new_node_id = node_id.to_i
    return false if blocked_node_ids.include?(new_node_id)
    push(blocked_node_ids: new_node_id)
  end

  def unblock_node(node_id)
    new_node_id = node_id.to_i
    pull(blocked_node_ids: new_node_id)
  end

  def blocked_users?
    blocked_user_ids.count > 0
  end

  def blocked_user?(user)
    uid = user.is_a?(User) ? user.id : user
    blocked_user_ids.include?(uid)
  end

  def block_user(user_id)
    user_id = user_id.to_i
    return false if self.blocked_user?(user_id)
    push(blocked_user_ids: user_id)
  end

  def unblock_user(user_id)
    user_id = user_id.to_i
    pull(blocked_user_ids: user_id)
  end

  def followed?(user)
    uid = user.is_a?(User) ? user.id : user
    following_ids.include?(uid)
  end

  def follow_user(user)
    return false if user.blank?
    following.push(user)
    Notification::Follow.notify(user: user, follower: self)
  end

  def followers_count
    follower_ids.count
  end

  def following_count
    following_ids.count
  end

  def unfollow_user(user)
    return false if user.blank?
    following.delete(user)
  end

  def favorites_count
    favorite_topic_ids.count
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
    return I18n.t("common.#{level}_user")
  end

  def letter_avatar_url(size)
    path = LetterAvatar.generate(self.login, size).sub('public/','/')

    "//#{Setting.domain}#{path}"
  end
end
