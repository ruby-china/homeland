@FormStorage =
  key: (element) ->
    "#{location.pathname} #{$(element).prop('id')}"

  init: ->
    if window.localStorage
      $(document).on 'input', 'textarea[name*=body]', ->
        textarea = $(this)
        localStorage.setItem(FormStorage.key(textarea), textarea.val())

      $(document).on 'submit', 'form', ->
        form = $(this)
        form.find('textarea[name*=body]').each ->
          localStorage.removeItem(FormStorage.key(this))

      $(document).on 'click', 'form a.reset', ->
        form = $(this).closest('form')
        form.find('textarea[name*=body]').each ->
          localStorage.removeItem(FormStorage.key(this))

  restore: ->
    if window.localStorage
      $('textarea[name*=body]').each ->
        textarea = $(this)
        if value = localStorage.getItem(FormStorage.key(textarea))
          textarea.val(value)
