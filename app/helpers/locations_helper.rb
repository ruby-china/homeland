module LocationsHelper
  def location_name_tag(location, _options = {})
    return '' if location.blank?
    name = location.is_a?(String) == true ? location : location.name
    link_to(name, location_users_path(name))
  end

  # 地区账号列表页面的链接
  #
  # @param location [String] 地区 Location 实例
  # @param user_type ['user', 'team'] 账号类型
  # @param _options [Hash] 额外的选项，传递给底层的 link_to 方法
  #
  def location_users_link(location, user_type, _options = {})
    path = if user_type == "user"
      location_users_path(id: location.name)
    else
      location_teams_path(id: location.name)
    end

    title = user_type == "user" ? "会员" : "团队"
    if current_page?(path)
      title
    else
      link_to title, path, _options
    end
  end
end
