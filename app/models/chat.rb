# coding: utf-8
class Chat
  include Mongoid::Document
  include Mongoid::Timestamps
  include Mongoid::SoftDelete
  
  belongs_to :node
  belongs_to :user
  field :author
  field :content  
end