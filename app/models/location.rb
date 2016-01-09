class Location < ActiveRecord::Base

  has_many :users

  scope :hot, -> { order(users_count: :desc) }

  validates :name, uniqueness: { case_sensitive: false }

  def self.find_by_name(name)
    return nil if name.blank?
    name = name.downcase.strip
    where(name: "'#{name}'").first
  end

  def self.find_or_create_by_name(name)
    unless (location = find_by_name(name))
      location = create(name: name.strip)
    end
    location
  end
end
