# coding: utf-8  
module ApplicationHelper
  # return the formatted flash[:notice] html
  def notice_message()
    if flash[:notice]
      result = '<div id="success_message">'+flash[:notice]+'</div>'
    else
      result = ''
    end
    
    return raw(result)
  end
  
  def admin?(user)
    return true if APP_CONFIG['admin_emails'].index(user.email)
    return false
  end
  
  def owner?(item)
    return false if item.blank?
    return if current_user.blank?
    item.user_id == current_user.id
  end
  
  def timeago(time, options = {})
    options[:class] ||= "timeago"
    content_tag(:abbr, time.to_s, options.merge(:title => time.getutc.iso8601)) if time
  end
end
