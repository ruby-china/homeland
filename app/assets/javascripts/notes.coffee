#= require_self
$(document).ready ->
  $("<div id='preview' class='wikistyle'></div>").insertAfter( $('#note_body') ) 

  $('.edit a').click ->
    $(this).parent().addClass('active')
    $('.preview a').parent().removeClass('active')
    $('#preview').hide()
    $('#note_body').show()
    false
    
  $('.preview a').click ->
    $(this).parent().addClass('active')
    $('.edit a').parent().removeClass('active')
    $('#preview').html('Loading...')
    $('#note_body').hide()
    $('#preview').show()
    $.post '/notes/preview', {body: $('#note_body').val()}, (data)->
      $('#preview').html(data)
      false
    false
