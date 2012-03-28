# TopicsController 下所有页面的 JS 功能
window.Topics =
  # 往话题编辑器里面插入图片代码
  appendImageFromUpload : (srcs) ->
    txtBox = $(".topic_editor")
    caret_pos = txtBox.caretPos()
    src_merged = ""
    for src in srcs
      src_merged = "![](#{src})\n"
    source = txtBox.val()
    before_text = source.slice(0, caret_pos)
    txtBox.val(before_text + src_merged + source.slice(caret_pos+1, source.count))
    txtBox.caretPos(caret_pos+src_merged.length)
    txtBox.focus()
    $("#add_image").jDialog.close()

  # 上传图片
  addImageClick : () ->
    opts =
      title:"插入图片"
      width: 350
      height: 145
      content: '<iframe src="/photos/tiny_new" frameborder="0" style="width:330px; height:145px;"></iframe>',
      close_on_body_click : false
    
    $("#add_image").jDialog(opts)
    return false

  # 回复
  reply : (floor,login) ->
    reply_body = $("#reply_body")
    new_text = "##{floor}楼 @#{login} "
    if reply_body.val().trim().length == 0
      new_text += ''
    else
      new_text = "\n#{new_text}"
    reply_body.focus().val(reply_body.val() + new_text)
    return false

  # 高亮楼层
  hightlightReply : (floor) ->
    $("#replies .reply").removeClass("light")
    $("#reply"+floor).addClass("light")

  # Ajax 回复后的事件
  replyCallback : (success, msg) ->
    $("#main .alert-message").remove()
    if success
      $("abbr.timeago",$("#replies .reply").last()).timeago()
      $("abbr.timeago",$("#replies .total")).timeago()
      $("#new_reply textarea").val('')
      App.notice(msg,'#reply')
    else
      App.alert(msg,'#reply')
    $("#new_reply textarea").focus()
    $('#btn_reply').button('reset')

  preview: (body) ->
    $("#preview").text "Loading..."

    $.post "/topics/preview",
      "body": body,
      (data) ->
        $("#preview").html data.body
      "json"

  hookPreview: (switcher, textarea) ->
    # put div#preview after textarea
    preview_box = $(document.createElement("div")).attr "id", "preview"
    preview_box.addClass("body")
    $(textarea).after preview_box
    preview_box.hide()

    $(".edit a",switcher).click ->
      $(".preview",switcher).removeClass("active")
      $(this).parent().addClass("active")
      $(preview_box).hide()
      $(textarea).show()
      false
    $(".preview a",switcher).click ->
      $(".edit",switcher).removeClass("active")
      $(this).parent().addClass("active")
      $(preview_box).show()
      $(textarea).hide()
      Topics.preview($(textarea).val())
      false

  initCloseWarning: (el, msg) ->
    return false if el.length == 0
    msg = "离开本页面将丢失未保存页面!" if !msg
    $("input[type=submit]").click ->
      $(window).unbind("beforeunload")
    el.change ->
      if el.val().length > 0
        $(window).bind "beforeunload", (e) ->
          if $.browser.msie
            e.returnValue = msg
          else
            return msg
      else
        $(window).unbind("beforeunload")
        
  favorite : (el) ->
    topic_id = $(el).data("id")
    if $(el).hasClass("small_bookmarked")
      hash = 
        type : "unfavorite"
      $.ajax
       url : "/topics/#{topic_id}/favorite"
       data : hash
       type : "POST"
       success : ->
         $(el).attr("title","收藏")
         $(el).attr("class","icon small_bookmark")
    else
      $.ajax
       url : "/topics/#{topic_id}/favorite"
       type : "POST"
       success : ->
         $(el).attr("title","取消收藏")
         $(el).attr("class","icon small_bookmarked")
    false
    
# pages ready
$(document).ready ->
  $("textarea").bind "keydown","ctrl+return",(el) ->
    if $(el.target).val().trim().length > 0
      $("#reply form").submit()
    return false

  Topics.initCloseWarning($("textarea.closewarning"))

  $("textarea").autogrow()

  $("#new_reply").submit () ->
    $('#btn_reply').button('loading')

  $("a.at_floor").live 'click', () ->
    Topics.hightlightReply($(this).data("floor"))

  $("a.small_reply").live 'click', () ->
    Topics.reply($(this).data("floor"), $(this).data("login"))
  
  Topics.hookPreview($(".editor_toolbar"), $(".topic_editor"))
  
  $("body").bind "keydown", "m", (el) ->
    $('#markdown_help_tip_modal').modal
      keyboard : true
      backdrop : true
      show : true

  # @ Reply
  logins = []
  login_exists = []
  if $("#topic_show .leader .name a").length > 0
    author_val =
      login : $("#topic_show .leader .name a").text(), 
      name : $("#topic_show .leader .name a").data('name')
    logins.push(author_val)
    login_exists.push(author_val.login)
  $('#replies span.name a').each (idx) ->
    val = 
      login : $(this).text()
      name : $(this).data('name')
    if $.inArray(val.login,login_exists) < 0
      login_exists.push(val.login)
      logins.push(val)
  App.atReplyable("textarea", logins)
