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
end
