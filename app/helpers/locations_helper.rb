# coding: utf-8  
module LocationsHelper
  def location_name_tag(location,options = {})
    result = link_to(location['_id'], location_path(location['_id']))
  end
end