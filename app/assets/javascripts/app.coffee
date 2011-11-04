window.App =
  loading : () ->
    console.log "loading..."
    
  # 警告信息显示, to 显示在那个dom前(可以用 css selector)
  alert : (msg,to) ->
    $(to).before("<div data-alert class='alert-message'><a class='close' href='#'>X</a>#{msg}</div>")

  # 成功信息显示, to 显示在那个dom前(可以用 css selector)
  notice : (msg,to) ->
    $(to).before("<div data-alert class='alert-message success'><a class='close' href='#'>X</a>#{msg}</div>")

$(document).ready ->  
  $("abbr.timeago").timeago()
  $(".alert-message").alert()
  $("a[rel=twipsy]").twipsy({ live: true })
  # 绑定评论框 Ctrl+Enter 提交事件
  $(".cell_comments_new textarea").bind "keydown","ctrl+return",(el) ->
    if $(el.target).val().trim().length > 0
      $(el.target).parent().parent().submit()
    return false