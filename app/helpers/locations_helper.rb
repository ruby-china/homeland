# coding: utf-8
module LocationsHelper
  def location_name_tag(location,options = {})
    return "" if location.blank?
    name = location.is_a?(String) == true ? location : location.name
    result = link_to(name, location_users_path(name))
  end
end
