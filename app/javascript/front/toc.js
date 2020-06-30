// Table of Contents for Markdown body
window.TOCView = Backbone.View.extend({
  el: "body",

  initialize(opts) {
    this.parentView = opts.parentView;
    const haveAnyHeaders = this.initHeadersInTopic();
    if (haveAnyHeaders) { return $(".toc-container").show(); }
  },

  initHeadersInTopic() {
    if ($(".markdown-toc .toc-container").length > 0) {
      return false;
    }
    const markdownEl = $(".markdown-toc");
    markdownEl.prepend(`\
<div class="toc-container dropdown pull-right">
  <button data-toggle="dropdown" class="btn btn-default">
    <i class="fa fa-list"></i> 目录
  </button>
  <div class="toc-panel dropdown-menu dropdown-menu-right">
    <div class="list-container">
      <ul class="list"></ul>
    </div>
  </div>
</div>\
`
    );

    const items = $.map(markdownEl.find("h1,h2,h3,h4,h5,h6"), function(el, _) {
      const level = el.tagName.replace("H", "");
      const anchor = el.id;
      return `<li class=\"toc-item toc-level-${level}\"> \
<a href=\"#${encodeURI(anchor)}\" class=\"toc-item-link\">${el.textContent}</a> \
</li>`;
    });
    if (items.length) {
      $(".toc-container .list").html(items.join(""));
      return true;
    } else {
      return false;
    }
  }
});
