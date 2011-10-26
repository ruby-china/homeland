# coding: utf-8  
class Section
  include Mongoid::Document
  include Mongoid::Timestamps

  field :name
  field :sort, :type => Integer, :default => 0
  has_many :nodes, :dependent => :destroy
  
  validates_presence_of :name
  validates_uniqueness_of :name
  
  
  default_scope desc(:sort)
end
