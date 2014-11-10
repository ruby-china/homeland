### 
paste.js is an interface to read data ( text / image ) from clipboard in different browsers. It also contains several hacks.

https://github.com/layerssss/paste.js
###

$ = window.jQuery
$.paste = (pasteContainer) ->
  console?.log "DEPRECATED: This method is deprecated. Please use $.fn.pastableNonInputable() instead."
  pm = Paste.mountNonInputable pasteContainer
  pm._container
$.fn.pastableNonInputable = ->
  for el in @
    Paste.mountNonInputable el
  @
$.fn.pastableTextarea = ->
  for el in @
    Paste.mountTextarea el
  @
$.fn.pastableContenteditable = ->
  for el in @
    Paste.mountContenteditable el
  @

dataURLtoBlob = (dataURL, sliceSize=512) ->
  return null unless m = dataURL.match /^data\:([^\;]+)\;base64\,(.+)$/
  [m, contentType, b64Data] = m
  byteCharacters = atob(b64Data)
  byteArrays = []
  offset = 0
  while offset < byteCharacters.length
    slice = byteCharacters.slice(offset, offset + sliceSize)
    byteNumbers = new Array(slice.length)
    i = 0
    while i < slice.length
      byteNumbers[i] = slice.charCodeAt(i)
      i++
    byteArray = new Uint8Array(byteNumbers)
    byteArrays.push byteArray
    offset += sliceSize
  new Blob byteArrays,
    type: contentType

createHiddenEditable = ->
  $(document.createElement 'div')
  .attr 'contenteditable', true
  .css
    width: 1
    height: 1
    position: 'fixed'
    left: -100
    overflow: 'hidden'

class Paste
  # Element to receive final events.
  _target: null

  # Actual element to do pasting.
  _container: null

  @mountNonInputable: (nonInputable)->
    paste = new Paste createHiddenEditable().appendTo(nonInputable), nonInputable
    $(nonInputable).on 'click', => paste._container.focus()

    paste._container.on 'focus', => $(nonInputable).addClass 'pastable-focus'
    paste._container.on 'blur', => $(nonInputable).removeClass 'pastable-focus'


  @mountTextarea: (textarea)->
    # Firefox & IE
    return @mountContenteditable textarea if -1 != navigator.userAgent.toLowerCase().indexOf('chrome')
    paste = new Paste createHiddenEditable().insertBefore(textarea), textarea
    ctlDown = false
    $(textarea).on 'keyup', (ev)-> 
      ctlDown = false if ev.keyCode in [17, 224]
    $(textarea).on 'keydown', (ev)-> 
      ctlDown = true if ev.keyCode in [17, 224]
      paste._container.focus() if ctlDown && ev.keyCode == 86
    $(paste._target).on 'pasteImage', =>
      $(textarea).focus()
    $(paste._target).on 'pasteText', =>
      $(textarea).focus()
  
    $(textarea).on 'focus', => $(textarea).addClass 'pastable-focus'
    $(textarea).on 'blur', => $(textarea).removeClass 'pastable-focus'

  @mountContenteditable: (contenteditable)->
    paste = new Paste contenteditable, contenteditable
    
    $(contenteditable).on 'focus', => $(contenteditable).addClass 'pastable-focus'
    $(contenteditable).on 'blur', => $(contenteditable).removeClass 'pastable-focus'


  constructor: (@_container, @_target)->
    @_container = $ @_container
    @_target = $ @_target
    .addClass 'pastable'
    @_container.on 'paste', (ev)=>
      if ev.originalEvent?.clipboardData?
        clipboardData = ev.originalEvent.clipboardData
        if clipboardData.items 
          # Chrome 
          for item in clipboardData.items
            if item.type.match /^image\//
              reader = new FileReader()
              reader.onload = (event)=>
                @_handleImage event.target.result
              reader.readAsDataURL item.getAsFile()
            if item.type == 'text/plain'
              item.getAsString (string)=>
                @_target.trigger 'pasteText', text: string
        else
          # Firefox & Safari(text-only)
          if -1 != Array.prototype.indexOf.call clipboardData.types, 'text/plain'
            text = clipboardData.getData 'Text'
            @_target.trigger 'pasteText', text: text
          @_checkImagesInContainer (src)=>
            @_handleImage src
      # IE
      if clipboardData = window.clipboardData 
        if (text = clipboardData.getData 'Text')?.length
          @_target.trigger 'pasteText', text: text
        else
          for file in clipboardData.files
            @_handleImage URL.createObjectURL(file)
            @_checkImagesInContainer ->

  _handleImage: (src)->
    loader = new Image()
    loader.onload = =>
      canvas = document.createElement 'canvas'
      canvas.width = loader.width
      canvas.height = loader.height
      ctx = canvas.getContext '2d'
      ctx.drawImage loader, 0, 0, canvas.width, canvas.height
      dataURL = null
      try 
        dataURL = canvas.toDataURL 'image/png'
        blob = dataURLtoBlob dataURL
      if dataURL
        @_target.trigger 'pasteImage',
          blob: blob
          dataURL: dataURL
          width: loader.width
          height: loader.height
    loader.src = src

  _checkImagesInContainer: (cb)->
    timespan = Math.floor 1000 * Math.random()
    img["_paste_marked_#{timespan}"] = true for img in @_container.find('img')
    setTimeout =>
      for img in @_container.find('img')
        cb img.src unless img["_paste_marked_#{timespan}"]
        $(img).remove()
    , 1
