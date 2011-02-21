# coding: utf-8  
class User
  include Mongoid::Document
  include Mongoid::Timestamps
  include Mongoid::Paperclip
  include AuthlogicModel
  
  field :name
  field :location
  field :bio
  field :website
  field :avatar
  field :verified, :type => Boolean, :default => false
  field :state, :type => Integer, :default => 1
  field :qq
  field :tagline  
  field :replies_count, :type => Integer, :default => 0  
  
  has_many :topics, :dependent => :destroy  
  has_many :notes
  has_many :replies
	embeds_many :authorizations
  
  attr_protected :username, :email, :name, :state, :verified
  attr_accessor :password_confirmation
  
  acts_as_authentic do |config|
    # Change this to your preferred login field
    config.login_field = 'username'
    config.merge_validates_uniqueness_of_login_field_options :scope => '_id', :case_sensitive => true
    config.ignore_blank_passwords = true #ignoring passwords
    config.validate_password_field = false #ignoring validations for password fields
  end

	#here we add required validations for a new record and pre-existing record
  validate do |user|
    if user.new_record? #adds validation if it is a new record
      user.errors.add(:password, "is required") if user.password.blank? 
      user.errors.add(:password_confirmation, "is required") if user.password_confirmation.blank?
      user.errors.add(:password, "Password and confirmation must match") if user.password != user.password_confirmation
    elsif !(!user.new_record? && user.password.blank? && user.password_confirmation.blank?) #adds validation only if password or password_confirmation are modified
      user.errors.add(:password, "is required") if user.password.blank?
      user.errors.add(:password_confirmation, "is required") if user.password_confirmation.blank?
      user.errors.add(:password, " and confirmation must match.") if user.password != user.password_confirmation
      user.errors.add(:password, " and confirmation should be atleast 4 characters long.") if user.password.length < 4 || user.password_confirmation.length < 4
    end
  end  
  
  validates_presence_of :name  
  validates_uniqueness_of :name

  before_create :default_value_for_create
  def default_value_for_create
    self.state = STATE[:normal]
  end
  
  # 注册邮件提醒
  after_create :send_welcome_mail
  def send_welcome_mail
    m = UserMailer.create_welcome(self)
    Thread.new { m.deliver }
	rescue => e
		logger.error { e }
  end
  
  # 封面图
  mount_uploader :avatar, AvatarUploader

  STATE = {
    :normal => 1,
    # 屏蔽
    :blocked => 2
  }

  def self.cached_count
    return Rails.cache.fetch("users/count",:expires_in => 1.hours) do
      self.count
    end
  end

	def self.create_from_hash(auth)  
		user = User.new
		user.name = auth["user_info"]["name"]  
		user.email = auth['user_info']['email']
		user.save(false)
		user.reset_persistence_token! #set persistence_token else sessions will not be created
		user
  end  
end
