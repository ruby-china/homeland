class Topic < ActiveRecord::Base
  validates_presence_of :user_id, :title, :body, :node_id
  belongs_to :node
  belongs_to :user
  belongs_to :last_reply_user, :class_name => "User"
  has_many :replies
  scope :recent, :order => "id desc"
end
