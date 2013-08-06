# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/
#
window.Pages = 
# 往话题编辑器里面插入代码模版
  appendCodesFromHint : (mode, language='') ->
    txtBox = $("#page_body")
    caret_pos = txtBox.caretPos()    
    if mode == "block"
      src_merged = "\n```#{language}\n\n```\n"      
    else
      src_merged = "``"      
    source = txtBox.val()
    before_text = source.slice(0, caret_pos)
    txtBox.val(before_text + src_merged + source.slice(caret_pos+1, source.count))
    if mode == "block"
      txtBox.caretPos(caret_pos+"\n```#{language}\n".length)
    else
      txtBox.caretPos(caret_pos+1)
    txtBox.focus()

$(document).ready ->
  $("<div id='preview' class='wikistyle'></div>").insertAfter( $('#page_body') ) 

  $('.edit a').click ->
    $(this).parent().addClass('active')
    $('.preview a').parent().removeClass('active')
    $('#preview').hide()
    $('#page_body').show()
    false
    
  $('.preview a').click ->
    $(this).parent().addClass('active')
    $('.edit a').parent().removeClass('active')
    $('#preview').html('Loading...')
    $('#page_body').hide()
    $('#preview').show()
    $.post '/wiki/preview', {body: $('#page_body').val()}, (data)->
      $('#preview').html(data)
      false
    false

  # pick up one lang and insert it into the textarea
  $("button.lang").on "click", ->
    # not sure IE supports data or not
    Pages.appendCodesFromHint("block", $(this).data('content') || $(this).attr('id') )
    $('button.close').click()

  $('button#confirm_code').on "click", ->
    Pages.appendCodesFromHint("block")
    $('button.close').click()

  # insert inline code
  $('#topic_add_single_code').on "click", ->
    Pages.appendCodesFromHint('inline')    