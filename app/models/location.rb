# coding: utf-8
class Location
  include Mongoid::Document

  field :name
  field :users_count, type: Integer, default: 0
  has_many :users

  scope :hot, -> { desc(:users_count) }

  validates_uniqueness_of :name, case_sensitive: false

  index name: 1

  def self.find_by_name(name)
    return nil if name.blank?
    name = name.downcase.strip
    query = name.match(/\p{Han}/) != nil ? name : /#{name}/i
    self.where(name: query).first
  end

  def self.find_or_create_by_name(name)
    if not location = self.find_by_name(name)
      location = self.create(name: name.strip)
    end
    location
  end
end