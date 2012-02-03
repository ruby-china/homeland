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

  likeable : (el) ->
    likeable_type = $(el).data("type")
    likeable_id = $(el).data("id")
    if $(el).data("state") != "liked"
      $.ajax
        url : "/likes"
        type : "POST"
        data : 
          type : likeable_type
          id : likeable_id
        success : (re) ->
          if re == "1"
            $(el).data("state","liked").attr("class","icon small_liked").attr("title", "取消喜欢")
          else
            App.alert("抱歉，系统异常，提交失败。")
    else
      $.ajax
        url : "/likes/#{likeable_id}"
        type : "DELETE"
        data : 
          type : likeable_type
        success : (re) ->
          if re == "1"
            $(el).data("state","").attr("class","icon small_like").attr("title", "取消喜欢")
          else
            App.alert("抱歉，系统异常，提交失败。")
    false

  # 绑定 @ 回复功能
  at_replyable : (el, logins) ->
    $(el).atWho
      debug : false
      data : logins

$(document).ready ->
  $("abbr.timeago").timeago()
  $(".alert-message").alert()
  $("a[rel=twipsy]").twipsy({ live: true })
  $("a[rel=popover]").popover
    live: true
    html: true

  # 用户头像 Popover
  $("a[rel=userpopover]").popover
    live: true
    html: true
    placement: (tip, ele) ->
      $element = $(ele)
      pos = $.extend({}, $element.offset(),
        width: ele.offsetWidth
        height: ele.offsetHeight
      )
      actualWidth = tip.offsetWidth
      actualHeight = tip.offsetHeight
      boundTop = $(document).scrollTop()
      boundLeft = $(document).scrollLeft()
      boundRight = boundLeft + $(window).width()
      boundBottom = boundTop + $(window).height()
      elementAbove =
        top: pos.top - actualHeight - this.options.offset
        left: pos.left + pos.width / 2 - actualWidth / 2
      elementBelow =
        top: pos.top + pos.height + this.options.offset
        left: pos.left + pos.width / 2 - actualWidth / 2
      elementLeft =
        top: pos.top + pos.height / 2 - actualHeight / 2
        left: pos.left - actualWidth - this.options.offset
      elementRight =
        top: pos.top + pos.height / 2 - actualHeight / 2
        left: pos.left + pos.width + this.options.offset
      isWithinBounds = (elementPosition) ->
        return boundTop < elementPosition.top && boundLeft < elementPosition.left && boundRight > (elementPosition.left + actualWidth) && boundBottom > (elementPosition.top + actualHeight)
      return 'below' if isWithinBounds(elementBelow)
      return 'right' if isWithinBounds(elementRight)
      return 'left' if isWithinBounds(elementLeft)
      return 'above' if isWithinBounds(elementAbove)
      return 'below'

  # 绑定评论框 Ctrl+Enter 提交事件
  $(".cell_comments_new textarea").bind "keydown","ctrl+return",(el) ->
    if $(el.target).val().trim().length > 0
      $(el.target).parent().parent().submit()
    return false
  
  # Choose 样式
  $("select").chosen()

  # CommentAble @ 回复功能
  commenter_logins = []
  $(".cell_comments .comment .info .name a").each (idx) ->
    name = $(this).text()
    if $.inArray(name,commenter_logins) < 0
      commenter_logins.push(name)
  App.at_replyable(".cell_comments_new textarea", commenter_logins)