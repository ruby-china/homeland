# TopicsController 下所有页面的 JS 功能
window.Topics =
  topic_id: null
  user_liked_reply_ids: []

window.TopicView = Backbone.View.extend
  el: "body"
  currentPageImageURLs : []
  clearHightTimer: null

  events:
    "click .navbar .topic-title": "scrollPage"
    "click #replies .reply .btn-reply": "reply"
    "click a.at_floor": "clickAtFloor"
    "click a.follow": "follow"
    "click a.bookmark": "bookmark"
    "click .btn-move-page": "scrollPage"
    "click .notify-updated .update": "updateReplies"
    "click #node-selector .nodes .name a": "nodeSelectorNodeSelected"
    "click .editor-toolbar .reply-to a.close": "unsetReplyTo"
    "tap .topics .topic": "topicRowClick"

  initialize: (opts) ->
    @parentView = opts.parentView

    @initComponents()
    @initCableUpdate()
    @initContentImageZoom()
    @initCloseWarning()
    @checkRepliesLikeStatus()
    @itemsUpdated()

  # called by new Reply insterted.
  itemsUpdated: ->
    @resetClearReplyHightTimer()
    @loadReplyToFloor()

  resetClearReplyHightTimer: ->
    clearTimeout(@clearHightTimer)
    @clearHightTimer = setTimeout ->
      $(".reply").removeClass("light")
    , 10000

  # 回复
  reply: (e) ->
    _el = $(e.target)
    reply_to_id = _el.data('id')
    @setReplyTo(reply_to_id)
    reply_body = $("#new_reply textarea")
    reply_body.focus()
    return false

  setReplyTo: (id) ->
    $('#reply_reply_to_id').val(id)
    replyEl = $(".reply[data-id=#{id}]")
    targetAnchor = replyEl.attr('id')
    replyToPanel = $(".editor-toolbar .reply-to")
    userNameEl = replyEl.find("a.user-name:first-child")
    replyToLink = replyToPanel.find(".user")
    replyToLink.attr("href", "##{targetAnchor}")
    replyToLink.text(userNameEl.text())
    replyToPanel.show()

  unsetReplyTo: ->
    $('#reply_reply_to_id').val('')
    replyToPanel = $(".editor-toolbar .reply-to")
    replyToPanel.hide()

    return false

  clickAtFloor: (e) ->
    floor = $(e.target).data('floor')
    @gotoFloor(floor)

  # 跳到指定楼。如果楼层在当前页，高亮该层，否则跳转到楼层所在页面并添
  # 加楼层的 anchor。返回楼层 DOM Element 的 jQuery 对象
  #
  # -   floor: 回复的楼层数，从1开始
  gotoFloor: (floor) ->
    replyEl = $("#reply#{floor}")

    @highlightReply(replyEl)

    replyEl

  # 高亮指定楼。取消其它楼的高亮
  #
  # -   replyEl: 需要高亮的 DOM Element，须要 jQuery 对象
  highlightReply: (replyEl) ->
    $("#replies .reply").removeClass("light")
    replyEl.addClass("light")

  # 异步更改用户 like 过的回复的 like 按钮的状态
  checkRepliesLikeStatus : () ->
    for id in Topics.user_liked_reply_ids
      el = $("#replies a.likeable[data-id=#{id}]")
      @parentView.likeableAsLiked(el)

  # Ajax 回复后的事件
  replyCallback : (success, msg) ->
    return if msg == ''
    $("#main .alert-message").remove()
    if success
      $("abbr.timeago",$("#replies .reply").last()).timeago()
      $("abbr.timeago",$("#replies .total")).timeago()
      $("#new_reply textarea").val('')
      $("#preview").text('')
      App.notice(msg,'#reply')
    else
      App.alert(msg,'#reply')
    $("#new_reply textarea").focus()
    $('#reply-button').button('reset')
    @resetClearReplyHightTimer()
    @unsetReplyTo()

  # 图片点击增加全屏预览功能
  initContentImageZoom : () ->
    exceptClasses = ["emoji", "twemoji", "media-object avatar-16"]
    imgEls = $(".markdown img")
    for el in imgEls
      if exceptClasses.indexOf($(el).attr("class")) == -1
        $(el).wrap("<a href='#{$(el).attr("src")}' class='zoom-image' data-action='zoom'></a>")

    # Bind click event
    if App.turbolinks || App.mobile
      $('a.zoom-image').attr("target","_blank")
    else
      $('a.zoom-image').fluidbox
        overlayColor: "#FFF"
        closeTrigger: [ {
          selector: 'window'
          event: 'scroll'
        } ]
    true

  preview: (body) ->
    $("#preview").text "Loading..."

    $.post "/topics/preview",
      "body": body,
      (data) ->
        $("#preview").html data.body
      "json"

  hookPreview: (switcher, textarea) ->
    # put div#preview after textarea
    self = @
    preview_box = $(document.createElement("div")).attr "id", "preview"
    preview_box.addClass("markdown form-control")
    $(textarea).after preview_box
    preview_box.hide()

    $(".edit a",switcher).click ->
      $(".preview",switcher).removeClass("active")
      $(this).parent().addClass("active")
      $(preview_box).hide()
      $(textarea).show()
      return false

    $(".preview a",switcher).click ->
      $(".edit",switcher).removeClass("active")
      $(this).parent().addClass("active")
      $(preview_box).show()
      $(textarea).hide()
      self.preview($(textarea).val())
      return false

  initCloseWarning: () ->
    text = $("textarea.closewarning")
    return false if text.length == 0
    msg = "离开本页面将丢失未保存页面!" if !msg
    $("input[type=submit]").click ->
      $(window).unbind("beforeunload")
    text.change ->
      if text.val().length > 0
        $(window).bind "beforeunload", (e) ->
          if $.browser.msie
            e.returnValue = msg
          else
            return msg
      else
        $(window).unbind("beforeunload")

  bookmark : (e) ->
    target = $(e.currentTarget)
    topic_id = target.data("id")
    link = $(".bookmark[data-id='#{topic_id}']")

    if link.hasClass("active")
      $.ajax
        url : "/topics/#{topic_id}/unfavorite"
        type : "DELETE"
      link.attr("title","收藏").removeClass("active")
    else
      $.post "/topics/#{topic_id}/favorite"
      link.attr("title","取消收藏").addClass("active")
    false

  follow : (e) ->
    target = $(e.currentTarget)
    topic_id = target.data("id")
    link = $(".follow[data-id='#{topic_id}']")

    if link.hasClass("active")
      $.ajax
        url : "/topics/#{topic_id}/unfollow"
        type : "DELETE"
      link.removeClass("active")
    else
      $.ajax
        url : "/topics/#{topic_id}/follow"
        type : "POST"
      link.addClass("active")
    false

  submitTextArea : (e) ->
    if $(e.target).val().trim().length > 0
      $("form#new_reply").submit()
    return false

  scrollPage: (e) ->
    target = $(e.currentTarget)
    moveType = target.data('type')
    opts =
      scrollTop: 0
    if moveType == 'bottom'
      opts.scrollTop = $('body').height()
    $("body, html").animate(opts, 300)
    return false

  initComponents : ->
    $("textarea.topic-editor").unbind "keydown.cr"
    $("textarea.topic-editor").bind "keydown.cr", "ctrl+return", (el) =>
      return @submitTextArea(el)

    $("textarea.topic-editor").unbind "keydown.mr"
    $("textarea.topic-editor").bind "keydown.mr", "Meta+return", (el) =>
      return @submitTextArea(el)

    # also highlight if hash is reply#
    matchResult = window.location.hash.match(/^#reply\-(\d+)$/)
    if matchResult?
      @highlightReply($("#reply-#{matchResult[1]}").parent())

    @hookPreview($(".editor-toolbar"), $(".topic-editor"))

    $("body").bind "keydown", "m", (el) ->
      $('#markdown_help_tip_modal').modal
        keyboard : true
        backdrop : true
        show : true

    # @ Mention complete
    App.mentionable("textarea", App.scanMentionableLogins($(".reply")))

    # Focus title field in new-topic page
    $("body[data-controller-name='topics'] #topic_title").focus()

    # init editor toolbar
    window._editor = new Editor()

  initCableUpdate: () ->
    self = @

    if not Topics.topic_id
      return

    if !window.repliesChannel
      window.repliesChannel = App.cable.subscriptions.create 'RepliesChannel',
        topicId: null

        connected: ->
          @subscribe()

        received: (json) =>
          return false if json.user_id == App.current_user_id
          return false if json.action != 'create'
          if App.windowInActive
            @updateReplies()
          else
            $(".notify-updated").show()

        subscribe: ->
          @topicId = Topics.topic_id
          @perform 'follow', topic_id: Topics.topic_id
    else if window.repliesChannel.topicId != Topics.topic_id
      window.repliesChannel.subscribe()

  updateReplies: () ->
    lastId = $("#replies .reply:last").data('id')
    if(!lastId)
      Turbolinks.visit(location.href)
      return false
    $.get "/topics/#{Topics.topic_id}/replies.js?last_id=#{lastId}", =>
      $(".notify-updated").hide()
      $("#new_reply textarea").focus()
    false

  nodeSelectorNodeSelected: (e) ->
    el = $(e.currentTarget)
    $("#node-selector").modal('hide')
    if $('.form input[name="topic[node_id]"]').length > 0
      e.preventDefault()
      nodeId = el.data('id')
      $('.form input[name="topic[node_id]"]').val(nodeId)
      $('#node-selector-button').html(el.text())
      return false
    else
      return true

  topicRowClick: (e) ->
    if !App.turbolinks
      return
    target = $(e.currentTarget).find(".title a")
    if e.target.tagName == "A"
      return true
    if $(e.target)[0] == target[0]
      return true

    e.preventDefault()

    $(e.currentTarget).addClass('topic-visited')
    Turbolinks.visit(target.attr('href'))
    return false

  loadReplyToFloor: ->
    _.each $(".reply-to-block"), (el) =>
      replyToId = $(el).data('reply-to-id')
      floor = $("#reply-#{replyToId}").data('floor');
      $(el).find('.reply-floor').text("\##{floor}")
