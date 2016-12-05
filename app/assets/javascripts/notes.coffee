window.NoteView = Backbone.View.extend
  el: "body"
  events:
    "click .editor-toolbar .edit a": "toggleEditView"
    "click .editor-toolbar .preview a": "togglePreviewView"

  initialize: (opts) ->
    @parentView = opts.parentView
    $("<div id='preview' class='markdown form-control' style='display:none;'></div>").insertAfter( $('#note_body') )
    window._editor = new Editor()

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
