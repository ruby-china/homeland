# Table of Contents for Markdown body
window.TOCView = Backbone.View.extend
  el: "body"

  initialize: (opts) ->
    @parentView = opts.parentView
    haveAnyHeaders = @initHeadersInTopic()
    $(".toc-container").show() if haveAnyHeaders

  initHeadersInTopic: ->
    if $(".markdown-toc .toc-container").size() > 0
      return false
    markdownEl = $(".markdown-toc")
    markdownEl.prepend """
    <div class="toc-container dropdown pull-right">
      <button data-toggle="dropdown" class="btn btn-default">
        <i class="fa fa-list"></i> 目录 <span class="caret"></span>
      </button>
      <div class="toc-panel dropdown-menu">
        <div class="list-container">
          <ul class="list"></ul>
        </div>
      </div>
    </div>
    """

    items = $.map markdownEl.find("h1,h2,h3,h4,h5,h6"), (el, _) ->
      level = el.tagName.replace("H", "")
      anchor = el.id
      "<li class=\"toc-item toc-level-#{level}\">
        <a href=\"##{encodeURI(anchor)}\" class=\"toc-item-link\">#{el.textContent}</a>
      </li>"
    if items.length
      $(".toc-container .list").html(items.join(""))
      true
    else
      false
