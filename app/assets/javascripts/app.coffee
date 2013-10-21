#= require jquery
#= require jquery_ujs
#= require jquery.turbolinks
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
#= require nprogress
#= require emoji_list
#= require faye
#= require notifier
#= require form_storage
#= require turbolinks
#= require topics
#= require pages
#= require notes
#= require_self

window.App =
  notifier : null,

  loading : () ->
    console.log "loading..."

  fixUrlDash : (url) ->
    url.replace(/\/\//g,"/").replace(/:\//,"://")

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

  # Use this method to redirect so that it can be stubbed in test
  gotoUrl: (url) ->
    Turbolinks.visit(url)

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

  atReplyable : (el, logins) ->
    return if logins.length == 0
    $(el).atwho
      at : "@"
      data : logins
      search_key : "search"
      tpl : "<li data-value='${login}'>${login} <small>${name}</small></li>"
    true

  initForDesktopView : () ->
    return if typeof(app_mobile) != "undefined"
    $("a[rel=twipsy]").tooltip()

    # CommentAble @ 回复功能
    commenters = App.scanLogins($(".cell_comments .comment .info .name a"))
    commenters = ({login: k, name: v, search: "#{k} #{v}"} for k, v of commenters)
    App.atReplyable(".cell_comments_new textarea", commenters)

  # scan logins in jQuery collection and returns as a object,
  # which key is login, and value is the name.
  scanLogins: (query) ->
    result = {}
    for e in query
      $e = $(e)
      result[$e.text()] = $e.attr('data-name')

    result

  initNotificationSubscribe : () ->
    return if not CURRENT_USER_ACCESS_TOKEN?
    faye = new Faye.Client(FAYE_SERVER_URL)
    notification_subscription = faye.subscribe "/notifications_count/#{CURRENT_USER_ACCESS_TOKEN}",(json) ->
      span = $("#user_notifications_count span")
      new_title = $(document).attr("title").replace(/\(\d+\) /,'')
      if json.count > 0
        span.addClass("badge-error")
        new_title = "(#{json.count}) #{new_title}"
        url = App.fixUrlDash("#{ROOT_URL}#{json.content_path}")
        console.log url
        $.notifier.notify("",json.title,json.content,url)
      else
        span.removeClass("badge-error")
      span.text(json.count)
      $(document).attr("title", new_title)
    true


  init : () ->
    App.initForDesktopView()
    FormStorage.restore()

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
      $('html, body').animate({ scrollTop: 0 },300)
      return false

    # Go top
    $(window).bind 'scroll resize', ->
      scroll_from_top = $(window).scrollTop()
      if scroll_from_top >= 1
        $("a.go_top").show()
      else
        $("a.go_top").hide()

# NProgress
NProgress.configure
  speed: 0

$(document).on 'page:fetch', ->
  NProgress.start()
$(document).on 'page:restore', ->
  NProgress.remove()
$(document).ready ->
  App.init()
  NProgress.done()

FormStorage.init()
