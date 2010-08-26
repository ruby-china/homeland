class Photo < ActiveRecord::Base
  attr_protected :user_id
  validates_presence_of :title
  belongs_to :user
  # 封面图
  has_attached_file :image,
    :default_style => :normal,
    :styles => {
      :small => "100>",
      :normal => "680>",
    },
    :url => "#{APP_CONFIG['upload_url']}/:class/:attachment/:hashed_path/:id_:style.jpg",
    :path => "#{APP_CONFIG['upload_root']}/:class/:attachment/:hashed_path/:id_:style.jpg",
    :default_url => "photo/:style.jpg"
    
  before_save :default_for_title
  def default_for_title
    self.title = "未命名" if self.title.blank?
  end
end
