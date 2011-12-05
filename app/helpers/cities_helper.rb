# coding: utf-8  
module CitiesHelper
  def city_name_tag(city,options = {})
    result = link_to(city['_id'], city_path(city['_id']))
    return result
  end
end