# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/
#


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
