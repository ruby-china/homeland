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
  
  def cachable_time_ago_in_words(from)
    if request.xhr?
      raw time_ago_in_words from
    else
      js_call = javascript_tag "document.write(DateHelper.timeAgoInWords(#{(from.to_i * 1000).to_json}));"
      raw "<noscript>on #{from.to_formatted_s(:long)}</noscript>#{js_call}"
    end
  end
end
