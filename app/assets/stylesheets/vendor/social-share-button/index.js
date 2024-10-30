require("jquery.qrcode.min")
require("./wechat");

window.SocialShareButton = {
  openUrl(url, width, height) {
    if (width == null) { width = 640; }
    if (height == null) { height = 480; }
    const left = (screen.width / 2) - (width / 2);
    const top = (screen.height * 0.3) - (height / 2);
    const opt = `width=${width},height=${height},left=${left},top=${top},menubar=no,status=no,location=no`;
    window.open(url, 'popup', opt);
    return false;
  },

  share(el) {
    if (el.getAttribute === null) {
      el = document.querySelector(el);
    }

    const site = el.getAttribute("data-site");
    const appkey = el.getAttribute("data-appkey") || '';
    const $parent = el.parentNode;
    let title = encodeURIComponent(el.getAttribute("data-" + site + "-title") || $parent.getAttribute('data-title') || '');
    const img = encodeURIComponent($parent.getAttribute("data-img") || '');
    let url = encodeURIComponent($parent.getAttribute("data-url") || '');
    const via = encodeURIComponent($parent.getAttribute("data-via") || '');
    const desc = encodeURIComponent($parent.getAttribute("data-desc") || ' ');

    // tracking click events if google analytics enabled
    const ga = window[window['GoogleAnalyticsObject'] || 'ga'];
    if (typeof ga === 'function') {
      ga('send', 'event', 'Social Share Button', 'click', site);
    }

    if (url.length === 0) {
      url = encodeURIComponent(location.href);
    }
    switch (site) {
      case "weibo":
        SocialShareButton.openUrl(`http://service.weibo.com/share/share.php?url=${url}&type=3&pic=${img}&title=${title}&appkey=${appkey}`, 620, 370);
        break;
      case "twitter":
        var hashtags = encodeURIComponent(el.getAttribute("data-" + site + "-hashtags") || $parent.getAttribute("data-hashtags") || '');
        var via_str = '';
        if (via.length > 0) { via_str = `&via=${via}`; }
        title = `${title}` + encodeURIComponent("\n\n") + `${url}`
        SocialShareButton.openUrl(`https://twitter.com/intent/tweet?text=${title}&hashtags=${hashtags}${via_str}`, 650, 300);
        break;
      case "facebook":
        SocialShareButton.openUrl(`http://www.facebook.com/sharer/sharer.php?u=${url}&display=popup&quote=${desc}`, 555, 400);
        break;
      case "wechat":
        if (!window.SocialShareWeChatButton) { throw new Error("You should require social-share-button/wechat to your application.js"); }
        window.SocialShareWeChatButton.qrcode({
          url: decodeURIComponent(url),
          header: el.getAttribute('title'),
          footer: el.getAttribute("data-wechat-footer")
        });
        break;
    }
    return false;
  }
};
