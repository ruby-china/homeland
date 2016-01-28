class Location < ApplicationRecord
  has_many :users

  scope :hot, -> { order(users_count: :desc) }

  validates :name, uniqueness: { case_sensitive: false}

  before_save { |loc| loc.name = loc.name.downcase.strip }

  def self.location_find_by_name(name)
    return nil if name.blank?
    name = name.downcase.strip
    where("name ~* ?", name).first
  end

  def self.location_find_or_create_by_name(name)
    name = name.strip
    unless (location = location_find_by_name(name))
      location = create(name: name)
    end
    location
  end
end
