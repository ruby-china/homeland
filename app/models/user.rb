# coding: utf-8  
class User

  
  include Mongoid::Document
  include Mongoid::Timestamps
  include Mongoid::BaseModel
  include Mongoid::SoftDelete
  include Redis::Objects
  extend OmniauthCallbacks   

  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable, :omniauthable
         
    

  field :login
  field :email
  field :location
  field :bio
  field :website
  field :github
  # 是否信任用户
  field :verified, :type => Boolean, :default => true
  field :state, :type => Integer, :default => 1
  field :guest, :type => Boolean, :default => false
  field :tagline  
  field :topics_count, :type => Integer, :default => 0
  field :replies_count, :type => Integer, :default => 0  
  field :likes_count, :type => Integer, :default => 0
  
  index :login
  index :email

  has_many :topics, :dependent => :destroy  
  has_many :notes
  has_many :replies, :dependent => :destroy
  embeds_many :authorizations
  has_many :posts
  has_many :notifications, :class_name => 'Notification::Base', :dependent => :delete
  has_many :photos
  has_many :likes

  def read_notifications(notifications)
    unread_ids = notifications.find_all{|notification| !notification.read?}.map(&:_id)
    if unread_ids.any?
      Notification::Base.where({
        :user_id => id,
        :_id.in  => unread_ids,
        :read    => false
      }).update_all(:read => true)
    end
  end

  attr_accessor :password_confirmation
  attr_protected :verified, :replies_count
  
  validates :login, :format => {:with => /\A\w+\z/, :message => '只允许数字、大小写字母和下划线'}, :length => {:in => 3..20}, :presence => true, :uniqueness => {:case_sensitive => false}
  
  has_and_belongs_to_many :following_nodes, :class_name => 'Node', :inverse_of => :followers
  has_and_belongs_to_many :following, :class_name => 'User', :inverse_of => :followers
  has_and_belongs_to_many :followers, :class_name => 'User', :inverse_of => :following

  scope :hot, desc(:replies_count, :topics_count)

  def self.find_for_database_authentication(conditions)
    login = conditions.delete(:login)
    self.where(:login => /^#{login}$/i).first
  end

  def password_required?
    return false if self.guest
    (authorizations.empty? || !password.blank?) && super  
  end
  
  def github_url
    return "" if self.github.blank?
    "http://github.com/#{self.github}"
  end
  
  
  
  # 是否是管理员
  def admin?
    return true if Setting.admin_emails.include?(self.email)
    return false
  end
  
  # 是否有 Wiki 维护权限
  def wiki_editor?
    return true if self.admin? or self.verified == true
    return false
  end
  
  def has_role?(role)
    case role
    when :admin
      return true if Setting.admin_emails.include?(self.email)
      return false 
    when :wiki_editor
      return true if self.admin? or self.verified == true
      return false
    when :member
      return true
    else
      false
    end
  end
  
  before_create :default_value_for_create
  def default_value_for_create
    self.state = STATE[:normal]
  end
  
  # 注册邮件提醒
  after_create :send_welcome_mail
  def send_welcome_mail
    UserMailer.welcome(self.id).deliver
  end

  STATE = {
    :normal => 1,
    # 屏蔽
    :blocked => 2
  }
  
  # 用邮件地址创建一个用户
  def self.find_or_create_guest(email)
    if u = find_by_email(email)
      return u
    else
      u = new(:email => email)
      u.login = email.split("@").first
      u.guest = true
      if u.save
        return u
      else
        Rails.logger.error("find_or_create_guest failed, #{u.errors.inspect}")
      end
    end
  end
  
  def update_with_password(params={})
    if !params[:current_password].blank? or !params[:password].blank? or !params[:password_confirmation].blank?
      super
    else
      params.delete(:current_password)
      self.update_without_password(params)
    end
  end
  
  def self.find_by_email(email)
    where(:email => email).first
  end
  
  def bind?(provider)
    self.authorizations.collect { |a| a.provider }.include?(provider)
  end
  
  def bind_service(response)
    provider = response["provider"]
    uid = response["uid"]
    authorizations.create(:provider => provider , :uid => uid ) 
  end
  
  # 是否读过 topic 的最近更新
  def topic_read?(topic)
    # 用 last_reply_id 作为 cache key ，以便不热门的数据自动被 Memcached 挤掉
    last_reply_id = topic.last_reply_id || -1
    Rails.cache.read("user:#{self.id}:topic_read:#{topic.id}") == last_reply_id
  end

  # 将 topic 的最后回复设置为已读
  def read_topic(topic)
    # 处理 last_reply_id 是空的情况
    last_reply_id = topic.last_reply_id || -1
    Rails.cache.write("user:#{self.id}:topic_read:#{topic.id}", last_reply_id)
  end
  
  # 收藏东西
  def like(likeable)
    Like.find_or_create_by(:likeable_id => likeable.id, 
                           :likeable_type => likeable.class,
                           :user_id => self.id)
  end
  
  # 取消收藏
  def unlike(likeable)
    Like.destroy_all(:conditions => {:likeable_id => likeable.id, 
                                     :likeable_type => likeable.class,
                                     :user_id => self.id})
  end

end
