window.TOCView = Backbone.View.extend
  el: "body"

  initialize: (opts) ->
    @parentView = opts.parentView
    haveAnyHeaders = @initHeadersInTopic()
    $(".toc-container").show() if haveAnyHeaders

  initHeadersInTopic: ->
    $article = $(".markdown")
    tocItems = $.map $article.find("h1,h2,h3,h4,h5,h6"), (element, _) ->
      level = element.tagName.replace("H", "")
      anchor = element.id
      "<li class=\"toc-item toc-level-#{level}\">
        <a href=\"##{encodeURI(anchor)}\" class=\"toc-item-link\">#{element.textContent}</a>
      </li>"
    if tocItems.length
      $(".toc-container .list").html(tocItems.join(""))
      true
    else
      false
