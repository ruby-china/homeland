class Section < ActiveRecord::Base
  validates_presence_of :name, :section_id
  validates_uniqueness_of :name
  has_many :nodes
end
