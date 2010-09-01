# coding: utf-8  
class User < ActiveRecord::Base
  attr_protected :email, :name, :state
  acts_as_authentic
  
  validates_presence_of :name
  validates_presence_of :password, :on => :create
  validates_uniqueness_of :name
  has_many :topics, :dependent => :destroy
  has_many :replies, :dependent => :destroy
  has_many :notes, :dependent => :destroy
  before_create :default_value_for_create
  def default_value_for_create
    self.state = STATE[:normal]
  end
  
  # 注册邮件提醒
  after_create :send_welcome_mail
  def send_welcome_mail
    m = UserMailer.create_welcome(self)
    Thread.new { m.deliver }
  end
  
  # 封面图
  has_attached_file :avatar,
    :default_style => :normal,
    :styles => {
      :small => "16x16#",
      :normal => "48x48#",
      :large => "80x80#",
    },
    :url => "#{APP_CONFIG['upload_url']}/:class/:attachment/:hashed_path/:id_:style.jpg",
    :path => "#{APP_CONFIG['upload_root']}/:class/:attachment/:hashed_path/:id_:style.jpg",
    :default_url => "avatar/:style.jpg"    

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
end
