/*
 * decaffeinate suggestions:
 * DS102: Remove unnecessary code created because of implicit returns
 * DS207: Consider shorter variations of null checks
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/master/docs/suggestions.md
 */
//= require jquery.qrcode.min

window.SocialShareWeChatButton = {
  init(opts) {
    if (opts == null) { opts = {}; }
    const $wDialog = `<div id='ss-wechat-dialog' class='ss-wechat-dialog'> \
<div class='wechat-popup-header'> \
<span>${opts.header}</span> \
<a href='#' onclick='return false;' class='wechat-popup-close'>×</a> \
</div> \
<div id='ss-wechat-dialog-qr' class='wechat-dialog-qr'></div> \
<div class='wechat-popup-footer'> \
${opts.footer} \
</div> \
</div>`;

    return $("body").append($wDialog);
  },

  bindEvents() {
    const $wContainer = $("#ss-wechat-dialog");
    return $wContainer.find(".wechat-popup-close").on("click", e => $wContainer.hide());
  },

  qrcode(opts) {
    if (opts == null) { opts = {}; }
    if (!$("#ss-wechat-dialog").length) {
      this.init(opts);
      this.bindEvents();
    }

    const $wBody = $('#ss-wechat-dialog-qr');
    $wBody.empty();
    $wBody.qrcode({
      width: 200,
      height: 200,
      text: opts.url
    });

    const $wContainer = $("#ss-wechat-dialog");
    let top = ($(window).height() - $wContainer.height()) / 2;
    if (top < 100) { top = 100; }
    const left = ($(window).width() - $wContainer.width()) / 2;

    $wContainer.css({
      top,
      left
    });

    return $wContainer.show();
  }
};
