# coding: utf-8
class CitiesCell < BaseCell
  
  cache :active_cities, :expires_in => 1.days
  def active_cities(opts)
    cities = opts[:cities].find().to_a.sort! do |x, y| 
      y['value']['count'] <=> x['value']['count']
    end
    @active_cities = cities[0..20]
    render 
  end
  
  # 活跃会员
  cache :active_users, :expires_in => 1.days
  def active_users(opts)
    @city = opts[:city]
    @active_users = User.where(:location => @city)
    render 
  end
  
  cache :recent_join_users, :expires_in => 1.hour
  def recent_join_users(opts)
    @city = opts[:city]
    @recent_join_users = User.where(:location => @city).recent.limit(20)
    render
  end
end