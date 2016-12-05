window.Editor = Backbone.View.extend
  el: '.editor-toolbar'

  events:
    "click #editor-upload-image": "browseUpload"
    "click .insert-codes a": "appendCodesFromHint"
    "click .pickup-emoji": "pickupEmoji"

  initialize: (opts) ->
    @initComponents()
    @initDropzone()

  initDropzone: ->
    self = @
    editor = $("textarea.topic-editor")
    editor.wrap "<div class=\"topic-editor-dropzone\"></div>"

    editor_dropzone = $('.topic-editor-dropzone')
    editor_dropzone.on 'paste', (event) =>
      self.handlePaste(event)

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
        self.showUploading()
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

  uploadFile: (item, filename) ->
    self = @
    formData = new FormData()
    formData.append "file", item, filename
    $.ajax
      url: '/photos'
      type: "POST"
      data: formData
      dataType: "JSON"
      processData: false
      contentType: false
      beforeSend: ->
        self.showUploading()
      success: (e, status, res) ->
        self.appendImageFromUpload([res.responseJSON.url])
        self.restoreUploaderStatus()
      error: (res) ->
        App.alert("上传失败")
        self.restoreUploaderStatus()
      complete: ->
        self.restoreUploaderStatus()

  handlePaste: (e) ->
    self = @
    pasteEvent = e.originalEvent
    if pasteEvent.clipboardData and pasteEvent.clipboardData.items
      image = self.isImage(pasteEvent)
      if image
        e.preventDefault()
        self.uploadFile image.getAsFile(), "image.png"

  isImage: (data) ->
    i = 0
    while i < data.clipboardData.items.length
      item = data.clipboardData.items[i]
      if item.type.indexOf("image") isnt -1
        return item
      i++
    return false

  browseUpload: (e) ->
    $(".topic-editor").focus()
    $('.topic-editor-dropzone').click()
    return false

  showUploading: () ->
    $("#editor-upload-image").hide()
    if $("#editor-upload-image").parent().find("span.loading").length == 0
      $("#editor-upload-image").before("<span class='loading'><i class='fa fa-circle-o-notch fa-spin'></i></span>")

  restoreUploaderStatus: ->
    $("#editor-upload-image").parent().find("span.loading").remove()
    $("#editor-upload-image").show()

  appendImageFromUpload : (srcs) ->
    src_merged = ""
    for src in srcs
      src_merged = "![](#{src})\n"
    @insertString(src_merged)
    return false

  # 往编辑器里面的光标前插入两个空白字符
  insertSpaces : (e) ->
    @insertString('  ')
    return false

  # 往编辑器里面插入代码模版
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

  insertString: (str) ->
    $target = $(".topic-editor")
    start = $target[0].selectionStart
    end = $target[0].selectionEnd
    $target.val($target.val().substring(0, start) + str + $target.val().substring(end));
    $target[0].selectionStart = $target[0].selectionEnd = start + str.length
    $target.focus()

  initComponents : ->
    # 绑定文本框 tab 按键事件
    $("textarea.topic-editor").unbind "keydown.tab"
    $("textarea.topic-editor").bind "keydown.tab", "tab", (el) =>
      return @insertSpaces(el)

    $("textarea.topic-editor").autogrow()


  pickupEmoji: () ->
    if !window._emojiModal
      window._emojiModal = new EmojiModalView()
    window._emojiModal.show()
    false

