// Table of Contents for Markdown body
window.TOCView = Backbone.View.extend({
  el: "body",

  initialize(opts) {
    this.parentView = opts.parentView;
    const haveAnyHeaders = this.initHeadersInTopic();
    if (haveAnyHeaders) {
      return $(".toc-container").show();
    }
  },

  initHeadersInTopic() {
    if ($(".markdown-toc .toc-container").length > 0) {
      return false;
    }
    const markdownEl = $(".markdown-toc");
    markdownEl.prepend(`\
<div class="toc-container dropdown">
  <button data-bs-toggle ="dropdown" class="btn btn-secondary">
    <i class="fa fa-list"></i> 目录
  </button>
  <div class="dropdown-menu dropdown-menu-end">
  </div>
</div>\
`);

    const items = $.map(markdownEl.find("h1,h2,h3,h4,h5,h6"), function (el, _) {
      const level = el.tagName.replace("H", "");
      const anchor = el.id;
      const href = `#${encodeURI(anchor)}`;
      return `<a href="${href}" class="dropdown-item toc-level-${level}">${el.textContent}</a>`;
    });
    if (items.length) {
      $(".toc-container .dropdown-menu").html(items.join(""));
      return true;
    } else {
      return false;
    }
  },
});
