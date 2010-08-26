# coding: utf-8  
class User < ActiveRecord::Base
  attr_protected :email, :name, :state
  acts_as_authentic
  
  validates_presence_of :email, :name, :password
  validates_uniqueness_of :email, :name
  validates_format_of     :email, :with => /^([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})$/i
  has_many :topics
  has_many :replies
  before_create :default_value_for_create
  def default_value_for_create
    self.state = STATE[:normal]
  end
  
  # 封面图
  has_attached_file :avatar,
    :default_style => :normal,
    :styles => {
      :small => "16x16#",
      :normal => "48x48#",
      :large => "80>",
    },
    :url => "#{APP_CONFIG['upload_url']}/:class/:attachment/:hashed_path/:id_:style.jpg",
    :path => "#{APP_CONFIG['upload_root']}/:class/:attachment/:hashed_path/:id_:style.jpg",
    :default_url => "avatar/:style.jpg"    

  STATE = {
    :normal => 1,
    # 屏蔽
    :blocked => 2
  }

  
end
