# TopicsController 下所有页面的 JS 功能
window.Topics =
  user_liked_reply_ids: []

window.TopicView = Backbone.View.extend
  el: "body"
  currentPageImageURLs : []

  events:
    "click #replies .reply .btn-reply": "reply"
    "click .btn-focus-reply": "reply"
    "click #topic-upload-image": "browseUpload"
    "click .insert-codes a": "appendCodesFromHint"
    "click a.at_floor": "clickAtFloor"
    "click a.follow": "follow"
    "click a.bookmark": "bookmark"
    "click .btn-move-page": "scrollPage"

  initialize: (opts) ->
    @parentView = opts.parentView

    @initComponents()
    @initDropzone()
    @initContentImageZoom()
    @initCloseWarning()
    @checkRepliesLikeStatus()


  initDropzone: ->
    self = @
    editor = $("textarea.topic-editor")
    editor.wrap "<div class=\"topic-editor-dropzone\"></div>"

    editor_dropzone = $('.topic-editor-dropzone')

    dropzone = editor_dropzone.dropzone(
      url: "/photos"
      dictDefaultMessage: ""
      clickable: true
      paramName: "file"
      maxFilesize: 20
      uploadMultiple: false
      headers:
        "X-CSRF-Token": $("meta[name=\"csrf-token\"]").attr("content")
      previewContainer: false

      processing: ->
        $(".div-dropzone-alert").alert "close"
        $("#topic-upload-image").hide()
        if $("#topic-upload-image").parent().find("span.loading").length == 0
          $("#topic-upload-image").before("<span class='loading'><i class='fa fa-circle-o-notch fa-spin'></i></span>")

      dragover: ->
        editor.addClass "div-dropzone-focus"
        return

      dragleave: ->
        editor.removeClass "div-dropzone-focus"
        return

      drop: ->
        editor.removeClass "div-dropzone-focus"
        editor.focus()
        return

      success: (header, res) ->
        self.appendImageFromUpload([res.url])
        return

      error: (temp, msg) ->
        App.alert(msg)
        return

      totaluploadprogress: (num) ->
        return

      sending: ->
        return

      queuecomplete: ->
        self.restoreUploaderStatus()
        return
    )

    $("textarea").pastableTextarea()
    .on 'pasteImage', (ev, data)->
      pasteOpts = 
        data: new FormData()
        processData: false
        contentType: false
      pasteOpts.data.append 'Filedata', data.blob, "pasted_image.#{data.blob.type.replace /^.+\//g, ''}"
      for hiddenField in $('#topic-upload-images').closest('form').find 'input[type="hidden"]'
        pasteOpts.data.append hiddenField.name, hiddenField.value
      pasteOpts[k] = v for k, v of opts 
      $.ajax pasteOpts
  browseUpload: (e) ->
    $(".topic-editor").focus()
    $('.topic-editor-dropzone').click()
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
    if floor
      new_text = "##{floor}楼 @#{login} "
    else
      new_text = ''
    if reply_body.val().trim().length == 0
      new_text += ''
    else
      new_text = "\n#{new_text}"
    reply_body.focus().val(reply_body.val() + new_text)
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

    # 绑定文本框 tab 按键事件
    $("textarea.topic-editor").unbind "keydown.tab"
    $("textarea.topic-editor").bind "keydown.tab", "tab", (el) =>
      return @insertSpaces(el)

    $("textarea.topic-editor").autogrow()

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
