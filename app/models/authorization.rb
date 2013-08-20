# coding: utf-8
class Authorization
  include Mongoid::Document
  include Mongoid::Timestamps
  include Mongoid::BaseModel

  field :provider
  field :uid, type: String
  embedded_in :user, :inverse_of => :authorizations

  validates_presence_of :uid, :provider
  validates_uniqueness_of :uid, :scope => :provider
end

