window.Topics =
  appendImageFromUpload : (srcs) ->
    txtBox = $(".topic_body_text_area")
    for src in srcs
      txtBox.val("#{txtBox.val()}[img]#{src}[/img]\n")
    txtBox.focus()
    $("#add_image").jDialog.close()


  addImageClick : () ->
    opts =
      title:"插入图片"
      width: 350
      height: 145
      content: '<iframe src="/photos/tiny_new" frameborder="0" style="width:330px; height:145px;"></iframe>',
      close_on_body_click : false
    
    $("#add_image").jDialog(opts)
    return false