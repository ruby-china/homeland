#= require jquery
#= require jquery_ujs
#= require bootstrap-alerts
#= require bootstrap-dropdown
#= require bootstrap-tabs
#= require bootstrap-twipsy
#= require bootstrap-buttons
#= require bootstrap-popover
#= require bootstrap-modal
#= require will_paginate
#= require jquery.jdialog
#= require jquery.timeago
#= require jquery.timeago.settings
#= require jquery.hotkeys
#= require jquery.chosen
#= require jquery.autogrow-textarea
#= require social-share-button
#= require jquery.atwho
#= require_self
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
          if parseInt(re) >= 0
            $(el).data("state","liked").attr("title", "取消喜欢")
            $('span',el).text("#{re}人喜欢")
            $("i.icon",el).attr("class","icon small_liked")
          else
            App.alert("抱歉，系统异常，提交失败。")
    else
      $.ajax
        url : "/likes/#{likeable_id}"
        type : "DELETE"
        data : 
          type : likeable_type
        success : (re) ->
          if parseInt(re)  >= 0
            $(el).data("state","").attr("title", "喜欢")
            $('span',el).text("#{re}人喜欢")
            $("i.icon",el).attr("class","icon small_like")
          else
            App.alert("抱歉，系统异常，提交失败。")
    false

  # 绑定 @ 回复功能
  atReplyable : (el, logins) ->
    return if logins.length == 0
    $(el).atWho "@"
      debug : false
      data : logins
      tpl : "<li data-keyname='${login}'>${login} <small>${name}</small></li>"
      
  initForDesktopView : () ->
    return if typeof(app_mobile) != "undefined"
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

    # CommentAble @ 回复功能
    commenters = []
    commenter_exists = []
    $(".cell_comments .comment .info .name a").each (idx) ->
      val = 
        login : $(this).text()
        name : $(this).data('name')
      if $.inArray(val.login,commenter_exists) < 0
         commenters.push(val) 
         commenter_exists.push(val.login)
    App.atReplyable(".cell_comments_new textarea", commenters)
      
$(document).ready ->
  App.initForDesktopView()
  
  $("abbr.timeago").timeago()
  $(".alert-message").alert()  

  # 绑定评论框 Ctrl+Enter 提交事件
  $(".cell_comments_new textarea").bind "keydown","ctrl+return",(el) ->
    if $(el.target).val().trim().length > 0
      $(el.target).parent().parent().submit()
    return false
  
  # Choose 样式
  $("select").chosen()
  
  # Go Top
  $("a.go_top").click () ->
    $('html, body').animate({ scrollTop: 0 },300);
    return false
  
