window.App =
  loading : () ->
    console.log "loading..."
    
  # 警告信息显示, to 显示在那个dom前(可以用 css selector)
  alert : (msg,to) ->
    $(to).before("<div data-alert class='alert-message'><a class='close' href='#'>X</a>#{msg}</div>")

  # 成功信息显示, to 显示在那个dom前(可以用 css selector)
  notice : (msg,to) ->
    $(to).before("<div data-alert class='alert-message success'><a class='close' href='#'>X</a>#{msg}</div>")
      
  openUrl : (url) ->
    window.open(url)
      
  shareTo : (site, title) ->
    url = encodeURIComponent(location.href)
    switch site
      when "weibo"
        App.openUrl('http://v.t.sina.com.cn/share/share.php?url=' + url + '&title=' + title + '&source=ruby-china&content=utf-8')
      when "twitter"
        App.openUrl('https://twitter.com/home?status=' + title + ' ' + url)
      when "douban"
        App.openUrl('http://www.douban.com/recommend/?url=' + url + '&title=' + title + '&v=1&r=1')

$(document).ready ->  
  $("abbr.timeago").timeago()
  $(".alert-message").alert()
  $("a[rel=twipsy]").twipsy({ live: true })
  $("a[rel=popover]").popover
	  live: true
	  html: true
  # 绑定评论框 Ctrl+Enter 提交事件
  $(".cell_comments_new textarea").bind "keydown","ctrl+return",(el) ->
    if $(el.target).val().trim().length > 0
      $(el.target).parent().parent().submit()
    return false
  $(".share_buttons a").click () ->
    App.shareTo($(this).data("site"), $(this).parent().data('title'))
    return false
    