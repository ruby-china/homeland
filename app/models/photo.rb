# coding: utf-8  
class Photo  
  include Mongoid::Document
  include Mongoid::Timestamps
  include Mongoid::Paperclip
  
  field :title
  field :image  
  
  belongs_to :user
  
  attr_protected :user_id
  validates_presence_of :title
  
  # 封面图
  mount_uploader :image, PhotoUploader
  
  # has_mongoid_attached_file :image,
  #   :default_style => :normal,
  #   :styles => {
  #     :small => "100>",
  #     :normal => "680>",
  #   },
  #   :url => "#{APP_CONFIG['upload_url']}/:class/:attachment/:hashed_path/:id_:style.jpg",
  #   :path => "#{APP_CONFIG['upload_root']}/:class/:attachment/:hashed_path/:id_:style.jpg",
  #   :default_url => "photo/:style.jpg"
    
  before_save :default_for_title
  def default_for_title
    self.title = "未命名" if self.title.blank?
  end
end
