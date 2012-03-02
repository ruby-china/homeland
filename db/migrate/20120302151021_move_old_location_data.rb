class MoveOldLocationData < Mongoid::Migration
  def self.up
    User.unscoped.each do |u|
      next if u.location.blank?
      location = Location.find_or_create_by_name(u.location)
      u.update_attribute(:location_id, location.id)
      location.update_attribute(:users_count, location.users_count + 1)
    end
  end

  def self.down
  end
end