# TopicsController 下所有页面的 JS 功能
window.Topics =
  replies_per_page: 50
  user_liked_reply_ids: []

window.TopicView = Backbone.View.extend
  el: "body"
  currentPageImageURLs : []

  events:
    "click #replies .reply .btn-reply": "reply"
    "click #topic-upload-image": "browseUpload"
    "click .insert-codes a": "appendCodesFromHint"
    "click a.at_floor": "clickAtFloor"
    "click .topic-detail a.follow": "follow"
    "click .topic-detail a.bookmark": "bookmark"

  initialize: (opts) ->
    @parentView = opts.parentView

    @initComponents()
    @initUploader()
    @initContentImageZoom()
    @initCloseWarning()
    @checkRepliesLikeStatus()

  initUploader: ->
    self = @
    opts =
      url : "/photos"
      type : "POST"
      beforeSend : () ->
        $("#topic-upload-image").hide()
        $("#topic-upload-image").before("<span class='loading'><i class='fa fa-circle-o-notch fa-spin'></i></span>")
      success : (result, status, xhr) ->
        self.restoreUploaderStatus()
        self.appendImageFromUpload([result])
      error : (result, status, errorThrown) ->
        self.restoreUploaderStatus()
        alert(errorThrown)

    $("#topic-upload-images").fileUpload opts

  browseUpload: (e) ->
    $(".topic-editor").focus()
    $("#topic-upload-images").click()
    return false

  restoreUploaderStatus: ->
    $("#topic-upload-image").parent().find("span.loading").remove()
    $("#topic-upload-image").show()

  appendImageFromUpload : (srcs) ->
    txtBox = $(".topic-editor")
    caret_pos = txtBox.caret('pos')
    src_merged = ""
    for src in srcs
      src_merged = "![](#{src})\n"
    source = txtBox.val()
    before_text = source.slice(0, caret_pos)
    txtBox.val(before_text + src_merged + source.slice(caret_pos+1, source.count))
    txtBox.caret('pos',caret_pos + src_merged.length)
    txtBox.focus()
    return false

  # 回复
  reply: (e) ->
    _el = $(e.target)
    floor = _el.data("floor")
    login = _el.data("login")
    reply_body = $("#new_reply textarea")
    new_text = "##{floor}楼 @#{login} "
    if reply_body.val().trim().length == 0
      new_text += ''
    else
      new_text = "\n#{new_text}"
    reply_body.focus().val(reply_body.val() + new_text)
    return false

  # Given floor, calculate which page this floor is in
  pageOfFloor: (floor) ->
    Math.floor((floor - 1) / Topics.replies_per_page) + 1

  clickAtFloor: (e) ->
    floor = $(e.target).data('floor')
    @gotoFloor(floor)

  # 跳到指定楼。如果楼层在当前页，高亮该层，否则跳转到楼层所在页面并添
  # 加楼层的 anchor。返回楼层 DOM Element 的 jQuery 对象
  #
  # -   floor: 回复的楼层数，从1开始
  gotoFloor: (floor) ->
    replyEl = $("#reply#{floor}")

    if replyEl.length > 0
      @highlightReply(replyEl)
    else
      page = @pageOfFloor(floor)
      # TODO: merge existing query string
      url = window.location.pathname + "?page=#{page}" + "#reply#{floor}"
      App.gotoUrl url

    replyEl

  # 高亮指定楼。取消其它楼的高亮
  #
  # -   replyEl: 需要高亮的 DOM Element，须要 jQuery 对象
  highlightReply: (replyEl) ->
    $("#replies .reply").removeClass("light")
    replyEl.addClass("light")

  # 异步更改用户 like 过的回复的 like 按钮的状态
  checkRepliesLikeStatus : () ->
    console.log Topics.user_liked_reply_ids
    for id in Topics.user_liked_reply_ids
      el = $("#replies a.likeable[data-id=#{id}]")
      @parentView.likeableAsLiked(el)

  # Ajax 回复后的事件
  replyCallback : (success, msg) ->
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

  # 图片点击增加全屏预览功能
  initContentImageZoom : () ->
    exceptClasses = ["emoji"]
    imgEls = $(".markdown img")
    for el in imgEls
      if exceptClasses.indexOf($(el).attr("class")) == -1
        $(el).wrap("<a href='#{$(el).attr("src")}' class='zoom-image' data-action='zoom'></a>")

    # Bind click event
    if App.mobile == true
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
    link = $(e.currentTarget)
    topic_id = link.data("id")
    if link.hasClass("followed")
      $.ajax
        url : "/topics/#{topic_id}/unfavorite"
        type : "DELETE"
      link.attr("title","收藏").removeClass("followed")
    else
      $.post "/topics/#{topic_id}/favorite"
      link.attr("title","取消收藏").addClass("followed")
    false

  follow : (e) ->
    link = $(e.currentTarget)
    topic_id = link.data("id")
    followed = link.data("followed")
    if followed
      $.ajax
        url : "/topics/#{topic_id}/unfollow"
        type : "DELETE"
      link.data("followed", false).removeClass("followed")
    else
      $.ajax
        url : "/topics/#{topic_id}/follow"
        type : "POST"
      link.data("followed", true).addClass("followed")
    false

  submitTextArea : (e) ->
    if $(e.target).val().trim().length > 0
      $("form#new_reply").submit()
    return false

  # 往话题编辑器里面的光标前插入两个空白字符
  insertSpaces : (e) ->
    target = e.target
    start = target.selectionStart
    end = target.selectionEnd
    $target = $(target)
    $target.val($target.val().substring(0, start) + "  " + $target.val().substring(end));
    target.selectionStart = target.selectionEnd = start + 2
    return false

  # 往话题编辑器里面插入代码模版
  appendCodesFromHint : (e) ->
    link = $(e.currentTarget)
    language = link.data("lang")
    txtBox = $(".topic-editor")
    caret_pos = txtBox.caret('pos')
    prefix_break = ""
    if txtBox.val().length > 0
      prefix_break = "\n"
    src_merged = "#{prefix_break }```#{language}\n\n```\n"
    source = txtBox.val()
    before_text = source.slice(0, caret_pos)
    txtBox.val(before_text + src_merged + source.slice(caret_pos+1, source.count))
    txtBox.caret('pos',caret_pos + src_merged.length - 5)
    txtBox.focus()
    txtBox.trigger('click')
    return false

  initComponents : ->
    $("textarea").unbind "keydown.cr"
    $("textarea").bind "keydown.cr","ctrl+return",(el) =>
      return @submitTextArea(el)

    $("textarea").unbind "keydown.mr"
    $("textarea").bind "keydown.mr","Meta+return",(el) =>
      return @submitTextArea(el)

    # 绑定文本框 tab 按键事件
    $("textarea").unbind "keydown"
    $("textarea").bind "keydown","tab",(el) =>
      return @insertSpaces(el)

    $("textarea").autogrow()

    # also highlight if hash is reply#
    matchResult = window.location.hash.match(/^#reply(\d+)$/)
    if matchResult?
      @highlightReply($("#reply#{matchResult[1]}"))

    @hookPreview($(".editor-toolbar"), $(".topic-editor"))

    $("body").bind "keydown", "m", (el) ->
      $('#markdown_help_tip_modal').modal
        keyboard : true
        backdrop : true
        show : true

    # @ Reply
    logins = App.scanLogins($("#topic-show .leader a[data-author]"))
    $.extend logins, App.scanLogins($('#replies span.name a'))
    logins = ({login: k, name: v, search: "#{k} #{v}"} for k, v of logins)
    App.atReplyable("textarea", logins)

    # Focus title field in new-topic page
    $("body[data-controller-name='topics'] #topic_title").focus()
