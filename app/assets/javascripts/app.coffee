#= require jquery
#= require jquery_ujs
#= require bootstrap-transition
#= require bootstrap-alert
#= require bootstrap-modal
#= require bootstrap-dropdown
#= require bootstrap-tab
#= require bootstrap-tooltip
#= require bootstrap-button
#= require will_paginate
#= require jquery.timeago
#= require jquery.timeago.settings
#= require jquery.hotkeys
#= require jquery.chosen
#= require jquery.autogrow-textarea
#= require jquery.html5-fileupload
#= require social-share-button
#= require jquery.atwho
#= require emoji_list
#= require_self
window.App =
  loading : () ->
    console.log "loading..."

  # 警告信息显示, to 显示在那个dom前(可以用 css selector)
  alert : (msg,to) ->
    $(".alert").remove()
    $(to).before("<div class='alert'><a class='close' href='#' data-dismiss='alert'>X</a>#{msg}</div>")

  # 成功信息显示, to 显示在那个dom前(可以用 css selector)
  notice : (msg,to) ->
    $(".alert").remove()
    $(to).before("<div class='alert alert-success'><a class='close' data-dismiss='alert' href='#'>X</a>#{msg}</div>")

  openUrl : (url) ->
    window.open(url)

  likeable : (el) ->
    $el = $(el)
    likeable_type = $el.data("type")
    likeable_id = $el.data("id")
    likes_count = parseInt($el.data("count"))
    if $el.data("state") != "liked"
      $.ajax
        url : "/likes"
        type : "POST"
        data :
          type : likeable_type
          id : likeable_id

      likes_count += 1
      $el.data('count', likes_count)
      App.likeableAsLiked(el)
    else
      $.ajax
        url : "/likes/#{likeable_id}"
        type : "DELETE"
        data :
          type : likeable_type
      if likes_count > 0
        likes_count -= 1
      $el.data("state","").data('count', likes_count).attr("title", "喜欢")
      if likes_count == 0
        $('span',el).text("喜欢")
      else
        $('span',el).text("#{likes_count}人喜欢")
      $("i.icon",el).attr("class","icon small_like")
    false

  likeableAsLiked : (el) ->
    likes_count = $(el).data("count")
    $(el).data("state","liked").attr("title", "取消喜欢")
    $('span',el).text("#{likes_count}人喜欢")
    $("i.icon",el).attr("class","icon small_liked")

  # 绑定 @ 回复功能
  atReplyable : (el, logins) ->
    return if logins.length == 0
    $(el).atWho "@"
      data : logins
      tpl : "<li data-value='${login}'>${login} <small>${name}</small></li>"

  initForDesktopView : () ->
    return if typeof(app_mobile) != "undefined"
    $("a[rel=twipsy]").tooltip()

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
  $(".alert").alert()
  $('.dropdown-toggle').dropdown()


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

  $(window).bind 'scroll resize', ->
    scroll_from_top = $(window).scrollTop()
    if scroll_from_top >= 1
      $("a.go_top").show()
    else
      $("a.go_top").hide()
