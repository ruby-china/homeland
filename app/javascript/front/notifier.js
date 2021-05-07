class Notifier {
  constructor() {
    this.setPermission = this.setPermission.bind(this);
    this.checkOrRequirePermission = this.checkOrRequirePermission.bind(this);
    this.enableNotification = false;
    this.checkOrRequirePermission();
  }

  hasSupport() {
    return window.webkitNotifications != null;
  }

  requestPermission(cb) {
    return window.webkitNotifications.requestPermission(cb);
  }

  setPermission() {
    if (this.hasPermission()) {
      $("#notification-alert a.close").click();
      return (this.enableNotification = true);
    } else if (window.webkitNotifications.checkPermission() === 2) {
      return $("#notification-alert a.close").click();
    }
  }

  hasPermission() {
    if (window.webkitNotifications.checkPermission() === 0) {
      return true;
    } else {
      return false;
    }
  }

  checkOrRequirePermission() {
    if (this.hasSupport()) {
      if (this.hasPermission()) {
        return (this.enableNotification = true);
      } else {
        if (window.webkitNotifications.checkPermission() !== 2) {
          return this.showTooltip();
        }
      }
    } else {
      return console.log(
        "Desktop notifications are not supported for this Browser/OS version yet."
      );
    }
  }

  showTooltip() {
    $(".breadcrumb").before(
      "<div class='alert alert-info' id='notification-alert'><a href='#' id='link_enable_notifications' style='color:green'>点击这里</a> 开启桌面提醒通知功能。 <a class='close' data-bs-dismiss ='alert' href='#'>×</a></div>"
    );
    $("#notification-alert").alert();
    return $("#notification-alert").on(
      "click",
      "a#link_enable_notifications",
      (e) => {
        e.preventDefault();
        return this.requestPermission(this.setPermission);
      }
    );
  }

  visitUrl(url) {
    return (window.location.href = url);
  }

  notify(avatar, title, content, url = null) {
    if (this.enableNotification) {
      let popup;
      if (!window.Notification) {
        popup = window.webkitNotifications.createNotification(
          avatar,
          title,
          content
        );
        if (url) {
          popup.onclick = function () {
            window.parent.focus();
            return $.notifier.visitUrl(url);
          };
        }
      } else {
        const opts = {
          body: content,
          onclick() {
            window.parent.focus();
            return $.notifier.visitUrl(url);
          },
        };
        popup = new window.Notification(title, opts);
      }
      return popup.show();
    }
  }
}

// setTimeout ( => popup.cancel() ), 12000
$.notifier = new Notifier();
