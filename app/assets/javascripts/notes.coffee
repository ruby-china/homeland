window.NoteView = Backbone.View.extend
  el: "body"
  events:
    "click .editor-toolbar .edit a": "toggleEditView"
    "click .editor-toolbar .preview a": "togglePreviewView"
    "click #note-upload-image": "browseUpload"
    "click .insert-codes a": "appendCodesFromHint"
    "click .pickup-emoji": "pickupEmoji"

  initialize: (opts) ->
    @parentView = opts.parentView
    @initDropzone()
    @initContentImageZoom()
    @initCloseWarning()
    @initComponents()
    $("<div id='preview' class='markdown' style='display:none;'></div>").insertAfter( $('#note_body') )


  toggleEditView: (e) ->
    $(e.target).parent().addClass('active')
    $('.preview a').parent().removeClass('active')
    $('#preview').hide()
    $('#note_body').show()
    false

  togglePreviewView: (e) ->
    $(e.target).parent().addClass('active')
    $('.edit a').parent().removeClass('active')
    $('#preview').html('Loading...')
    $('#note_body').hide()
    $('#preview').show()
    $.post '/notes/preview', {body: $('#note_body').val()}, (data)->
      $('#preview').html(data)
      false
    false

  initDropzone: ->
    self = @
    editor = $("textarea.note-editor")
    editor.wrap "<div class=\"note-editor-dropzone\"></div>"

    editor_dropzone = $('.note-editor-dropzone')
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

  initComponents : ->
    # 绑定文本框 tab 按键事件
    $("textarea.note-editor").unbind "keydown.tab"
    $("textarea.note-editor").bind "keydown.tab", "tab", (el) =>
      return @insertSpaces(el)

    $("textarea.note-editor").autogrow()

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
    $(".note-editor").focus()
    $('.note-editor-dropzone').click()
    return false

  showUploading: () ->
    $("#note-upload-image").hide()
    if $("#note-upload-image").parent().find("span.loading").length == 0
      $("#note-upload-image").before("<span class='loading'><i class='fa fa-circle-o-notch fa-spin'></i></span>")

  restoreUploaderStatus: ->
    $("#note-upload-image").parent().find("span.loading").remove()
    $("#note-upload-image").show()

  appendImageFromUpload : (srcs) ->
    src_merged = ""
    for src in srcs
      src_merged = "![](#{src})\n"
    @insertString(src_merged)
    return false

  initContentImageZoom : () ->
    exceptClasses = ["emoji", "twemoji"]
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

  # 往话题编辑器里面的光标前插入两个空白字符
  insertSpaces : (e) ->
    @insertString('  ')
    return false

  # 往话题编辑器里面插入代码模版
  appendCodesFromHint : (e) ->
    link = $(e.currentTarget)
    language = link.data("lang")
    txtBox = $(".note-editor")
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
    $target = $(".note-editor")
    start = $target[0].selectionStart
    end = $target[0].selectionEnd
    $target.val($target.val().substring(0, start) + str + $target.val().substring(end));
    $target[0].selectionStart = $target[0].selectionEnd = start + str.length
    $target.focus()

  pickupEmoji: () ->
    if !window._emojiModal
      window._emojiModal = new EmojiModalView()
    window._emojiModal.show()
    false
