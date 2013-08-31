# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/
#
window.Pages =
# 往话题编辑器里面插入代码模版
  test : () ->
    alert('test');

  init : () ->
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

$(document).ready ->
  if $('body').data('controller-name') in ['pages']
    Pages.init()
