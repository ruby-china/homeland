#= require jquery2
#= require jquery_ujs
#= require bootstrap.min
#= require jquery.mobile-events
#= require underscore
#= require backbone
#= require will_paginate
#= require jquery.timeago
#= require jquery.timeago.settings
#= require jquery.hotkeys
#= require jquery.autogrow-textarea
#= require tooltipster.bundle.min
#= require dropzone
#= require jquery.fluidbox.min
#= require social-share-button
#= require social-share-button/wechat
#= require jquery.atwho
#= require emoji-data
#= require emoji-modal
#= require notifier
#= require action_cable
#= require form_storage
#= require topics
#= require pages
#= require notes
#= require turbolinks
#= require google_analytics
#= require jquery.infinitescroll.min
#= require d3.min
#= require cal-heatmap.min
#= require_self

AppView = Backbone.View.extend
  el: "body"
  repliesPerPage: 50
  windowInActive: true

  events:
    "click a.likeable": "likeable"
    "click .header .form-search .btn-search": "openHeaderSearchBox"
    "click .header .form-search .btn-close": "closeHeaderSearchBox"
    "click a.button-block-user": "blockUser"
    "click a.button-follow-user": "followUser"
    "click a.button-block-node": "blockNode"
    "click a.rucaptcha-image-box": "reLoadRucaptchaImage"

  initialize: ->
    FormStorage.restore()
    @initForDesktopView()
    @initComponents()
    @initScrollEvent()
    @initInfiniteScroll()
    @initCable()
    @restoreHeaderSearchBox()

    if $('body').data('controller-name') in ['topics', 'replies']
      window._topicView = new TopicView({parentView: @})

    if $('body').data('controller-name') in ['pages']
      window._pageView = new PageView({parentView: @})

    if $('body').data('controller-name') in ['notes']
      window._noteView = new NoteView({parentView: @})

  initComponents: () ->
    $("abbr.timeago").timeago()
    $(".alert").alert()
    $('.dropdown-toggle').dropdown()
    $('[data-toggle="tooltip"]').tooltip()

    # 绑定评论框 Ctrl+Enter 提交事件
    $(".cell_comments_new textarea").unbind "keydown"
    $(".cell_comments_new textarea").bind "keydown", "ctrl+return", (el) ->
      if $(el.target).val().trim().length > 0
        $(el.target).parent().parent().submit()
      return false

    $(window).off "blur.inactive focus.inactive"
    $(window).on "blur.inactive focus.inactive", @updateWindowActiveState

    # Likeable Popover
    $('a.likeable[data-count!=0]').tooltipster
      content: "Loading..."
      theme: 'tooltipster-shadow'
      side: 'bottom'
      maxWidth: 230
      interactive: true
      contentAsHTML: true
      triggerClose:
        mouseleave: true
      functionBefore: (instance, helper) ->
        $target = $(helper.origin)
        if $target.data('remote-loaded') is 1
          return

        likeable_type = $target.data("type")
        likeable_id = $target.data("id")
        data =
          type: likeable_type
          id: likeable_id
        $.ajax
          url: '/likes'
          data: data
          success: (html) ->
            if html.length is 0
              $target.data('remote-loaded', 1)
              instance.hide()
              instance.destroy()
            else
              instance.content(html)
              $target.data('remote-loaded', 1)

  initForDesktopView : () ->
    return if App.mobile != false
    $("a[rel=twipsy]").tooltip()

    # CommentAble @ 回复功能
    App.atReplyable(".cell_comments_new textarea")

  likeable : (e) ->
    if !App.isLogined()
      location.href = "/account/sign_in"
      return false

    $target = $(e.currentTarget)
    likeable_type = $target.data("type")
    likeable_id = $target.data("id")
    likes_count = parseInt($target.data("count"))

    $el = $(".likeable[data-type='#{likeable_type}'][data-id='#{likeable_id}']")

    if $el.data("state") != "active"
      $.ajax
        url : "/likes"
        type : "POST"
        data :
          type : likeable_type
          id : likeable_id

      likes_count += 1
      $el.data('count', likes_count)
      @likeableAsLiked($el)
      $("i.fa", $el).attr("class","fa fa-heart")
    else
      $.ajax
        url : "/likes/#{likeable_id}"
        type : "DELETE"
        data :
          type : likeable_type
      if likes_count > 0
        likes_count -= 1
      $el.data("state","").data('count', likes_count).attr("title", "").removeClass("active")
      if likes_count == 0
        $('span', $el).text("")
      else
        $('span', $el).text("#{likes_count} 个赞")
      $("i.fa", $el).attr("class","fa fa-heart-o")
    $el.data("remote-loaded", 0)
    false

  likeableAsLiked : (el) ->
    likes_count = el.data("count")
    el.data("state","active").attr("title", "取消赞").addClass("active")
    $('span',el).text("#{likes_count} 个赞")
    $("i.fa",el).attr("class","fa fa-heart")

  initCable: () ->
    if !window.notificationChannel && App.isLogined()
      window.notificationChannel = App.cable.subscriptions.create "NotificationsChannel",
        connected: ->
          setTimeout =>
            @subscribe()
            $(window).on 'unload', -> window.notificationChannel.unsubscribe()
            $(document).on 'page:change', -> window.notificationChannel.subscribe()
          , 1000

        received: (data) =>
          @receivedNotificationCount(data)

        subscribe: ->
          @perform 'subscribed'

        unsubscribe: ->
          @perform 'unsubscribed'

  receivedNotificationCount : (json) ->
    console.log 'receivedNotificationCount', json
    span = $(".notification-count span")
    link = $(".notification-count a")
    new_title = document.title.replace(/^\(\d+\) /,'')
    if json.count > 0
      span.show()
      new_title = "(#{json.count}) #{new_title}"
      url = App.fixUrlDash("#{App.root_url}#{json.content_path}")
      $.notifier.notify("",json.title,json.content,url)
      link.addClass("new")
    else
      span.hide()
      link.removeClass("new")
    span.text(json.count)
    document.title = new_title

  restoreHeaderSearchBox: ->
    $searchInput = $(".header .form-search input")

    if location.pathname != "/search"
      $searchInput.val("")
    else
      results = new RegExp('[\?&]q=([^&#]*)').exec(window.location.href)
      q = results && decodeURIComponent(results[1])
      $searchInput.val(q)

  openHeaderSearchBox: (e) ->
    $(".header .form-search").addClass("active")
    $(".header .form-search input").focus()
    return false

  closeHeaderSearchBox: (e) ->
    $(".header .form-search input").val("")
    $(".header .form-search").removeClass("active")
    return false

  followUser: (e) ->
    btn = $(e.currentTarget)
    userId = btn.data("id")
    span = btn.find("span")
    followerCounter = $(".follow-info .followers[data-login=#{userId}] .counter")
    if btn.hasClass("active")
      $.ajax
        url: "/#{userId}/unfollow"
        type: "POST"
        success: (res) ->
          if res.code == 0
            btn.removeClass('active')
            span.text("关注")
            followerCounter.text(res.data.followers_count)
    else
      $.ajax
        url: "/#{userId}/follow"
        type: 'POST'
        success: (res) ->
          if res.code == 0
            btn.addClass('active').attr("title", "")
            span.text("取消关注")
            followerCounter.text(res.data.followers_count)
    return false

  blockUser: (e) ->
    btn = $(e.currentTarget)
    userId = btn.data("id")
    span = btn.find("span")
    if btn.hasClass("active")
      $.post("/#{userId}/unblock")
      btn.removeClass('active').attr("title", "忽略后，社区首页列表将不会显示此用户发布的内容。")
      span.text("屏蔽")
    else
      $.post("/#{userId}/block")
      btn.addClass('active').attr("title", "")
      span.text("取消屏蔽")
    return false

  blockNode: (e) ->
    btn = $(e.currentTarget)
    nodeId = btn.data("id")
    span = btn.find("span")
    if btn.hasClass("active")
      $.post("/nodes/#{nodeId}/unblock")
      btn.removeClass('active').attr("title", "忽略后，社区首页列表将不会显示这里的内容。")
      span.text("忽略节点")
    else
      $.post("/nodes/#{nodeId}/block")
      btn.addClass('active').attr("title", "")
      span.text("取消屏蔽")
    return false

  reLoadRucaptchaImage: (e) ->
    btn = $(e.currentTarget)
    img = btn.find('img:first')
    currentSrc = img.attr('src')
    img.attr('src', currentSrc.split('?')[0] + '?' + (new Date()).getTime())
    return false

  updateWindowActiveState: (e) ->
    prevType = $(this).data("prevType")

    if prevType != e.type
      switch (e.type)
        when "blur"
          @windowInActive = false
        when "focus"
          @windowInActive = true

    $(this).data("prevType", e.type)

  initInfiniteScroll: ->
    $('.infinite-scroll .item-list').infinitescroll
      nextSelector: '.pagination .next a'
      navSelector: '.pagination'
      itemSelector: '.topic, .notification-group'
      extraScrollPx: 200
      bufferPx: 50
      localMode: true
      loading:
        finishedMsg: '<div style="text-align: center; padding: 5px;">已到末尾</div>'
        msgText: '<div style="text-align: center; padding: 5px;">载入中...</div>'
        img: 'data:image/gif;base64,R0lGODlhAQABAIAAAP///wAAACH5BAEAAAAALAAAAAABAAEAAAICRAEAOw=='

  initScrollEvent: ->
    $(window).off('scroll.navbar-fixed')
    $(window).on('scroll.navbar-fixed', @toggleNavbarFixed)
    @toggleNavbarFixed()

  toggleNavbarFixed: (e) ->
    top = $(window).scrollTop()
    if top >= 50
      $(".header .navbar").addClass('navbar-fixed-active')
    else
      $(".header .navbar").removeClass('navbar-fixed-active')

    return if $(".navbar-topic-title").size() == 0
    if top >= 50
      $(".header .navbar").addClass('fixed-title')
    else
      $(".header .navbar").removeClass('fixed-title')


window.App =
  turbolinks: false
  mobile: false
  locale: 'zh-CN'
  notifier : null
  current_user_id: null
  access_token : ''
  asset_url : ''
  twemoji_url: 'https://twemoji.maxcdn.com/'
  root_url : ''
  cable: ActionCable.createConsumer()

  isLogined : ->
    App.current_user_id != null

  loading : () ->
    console.log "loading..."

  fixUrlDash : (url) ->
    url.replace(/\/\//g,"/").replace(/:\//,"://")

  # 警告信息显示, to 显示在那个dom前(可以用 css selector)
  alert : (msg,to) ->
    $(".alert").remove()
    $(to).before("<div class='alert alert-warning'><a class='close' href='#' data-dismiss='alert'><i class='fa fa-close'></i></a>#{msg}</div>")

  # 成功信息显示, to 显示在那个dom前(可以用 css selector)
  notice : (msg,to) ->
    $(".alert").remove()
    $(to).before("<div class='alert alert-success'><a class='close' data-dismiss='alert' href='#'><i class='fa fa-close'></i></a>#{msg}</div>")

  openUrl : (url) ->
    window.open(url)

  # Use this method to redirect so that it can be stubbed in test
  gotoUrl: (url) ->
    Turbolinks.visit(url)

  # scan logins in jQuery collection and returns as a object,
  # which key is login, and value is the name.
  scanLogins: (query) ->
    result = {}
    for e in query
      $e = $(e)
      result[$e.text()] = $e.attr('data-name')
    result

  atReplyable : (el, logins) ->
    $(el).atwho
      at : "@"
      searchKey: 'login'
      callbacks:
        filter: (query, data, searchKey) ->
          return data
        sorter: (query, items, searchKey) ->
          return items
        remoteFilter: (query, callback) ->
          $.getJSON '/search/users.json', { q: query }, (data) ->
            callback(data)
      displayTpl : "<li data-value='${login}'><img src='${avatar_url}' height='20' width='20'/> ${login} <small>${name}</small></li>"
      insertTpl : "@${login}"
    .atwho
      at : ":"
      searchKey: 'code'
      data : window.EMOJI_LIST
      displayTpl : "<li data-value='${code}'><img src='#{App.twemoji_url}/svg/${url}.svg' class='twemoji' /> ${code} </li>"
      insertTpl: "${code}"
    true


document.addEventListener 'turbolinks:load',  ->
  window._appView = new AppView()

document.addEventListener 'turbolinks:click', (event) ->
  if event.target.getAttribute('href').charAt(0) is '#'
    event.preventDefault()

FormStorage.init()
