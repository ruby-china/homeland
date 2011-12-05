# coding: utf-8
class LocationsCell < BaseCell
  
  cache :active_locations, :expires_in => 1.days
  def active_locations(opts)
    locations = opts[:locations].find().to_a.sort! do |x, y| 
      y['value']['count'] <=> x['value']['count']
    end
    @active_locations = locations[0..20]
    render 
  end
  
  # 活跃会员
  cache :active_users, :expires_in => 1.days
  def active_users(opts)
    @location = opts[:location]
    @active_users = User.where(:location => @location)
    render 
  end
  
  cache :recent_join_users, :expires_in => 1.hour
  def recent_join_users(opts)
    @location = opts[:location]
    @recent_join_users = User.where(:location => @location).recent.limit(20)
    render
  end
end