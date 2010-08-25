class Node < ActiveRecord::Base
  validates_presence_of :name
  validates_uniqueness_of :name
  belongs_to :section
  has_many :topics
end
