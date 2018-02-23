# frozen_string_literal: true

module LocationsHelper
  def location_name_tag(location, _options = {})
    return "" if location.blank?
    name = location.is_a?(String) == true ? location : location.name
    link_to(name, location_users_path(name))
  end
end
