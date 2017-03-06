window.TOCView = Backbone.View.extend
  el: "body"
  events:
    # for desktop
    "mouseover #toc-link": "displayTOCPanel"
    "click": "hideTOCPanel"

    # for mobile devices
    "touchend #toc-link": "displayTOCPanel"
    "click #close-toc-panel": "hideTOCPanel"

  initialize: (opts) ->
    @parentView = opts.parentView
    haveAnyHeaders = @initHeadersInTopic()
    $(".toc-container").show() if haveAnyHeaders

  initHeadersInTopic: ->
    $article = $("#article")
    tocItems = $.map $article.find("h1,h2,h3,h4,h5,h6"), (element, _) ->
      level = element.tagName.replace("H", "")
      anchor = element.id
      "<li class=\"toc-item toc-level-#{level}\">
        <a href=\"##{encodeURI(anchor)}\" class=\"toc-item-link\">#{element.textContent}</a>
      </li>"
    if tocItems.length
      $("#toc-list").html(tocItems.join(""))
      true
    else
      false

  displayTOCPanel: (e) ->
    $(".toc-panel").show()
    false

  hideTOCPanel: (e) ->
    $(".toc-panel").hide()