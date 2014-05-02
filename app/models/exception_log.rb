# coding: utf-8
class ExceptionLog
  include Mongoid::Document
  include Mongoid::Timestamps
  include Mongoid::BaseModel
  
  field :title
  field :body
end
