class User < ActiveRecord::Base
  validates_presence_of :email, :name, :passwd
  validates_uniqueness_of :email, :name
  has_many :topics
  has_many :replies
  
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
