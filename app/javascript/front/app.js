import i18n from "homeland/i18n";

require("./emoji-modal");
require("./notifier");

const AppView = Backbone.View.extend({
  el: "body",
  repliesPerPage: 50,
  windowInActive: true,

  events: {
    "click a.likeable": "likeable",
    "click .header .form-search .btn-search": "openHeaderSearchBox",
    "click .header .form-search .btn-close": "closeHeaderSearchBox",
    "click a.button-block-user": "blockUser",
    "click a.button-follow-user": "followUser",
    "click a.button-block-node": "blockNode",
    "click a.rucaptcha-image-box": "reLoadRucaptchaImage",
    "click .topics .topic": "visitTopic",
  },

  initialize() {
    let needle;
    this.initForDesktopView();
    this.initComponents();
    this.initScrollEvent();
    this.initInfiniteScroll();
    this.initCable();
    this.restoreHeaderSearchBox();

    if (
      ((needle = $("body").data("controller-name")),
      ["topics", "replies"].includes(needle))
    ) {
      window._topicView = new TopicView({ parentView: this });
    }

    return (window._tocView = new TOCView({ parentView: this }));
  },

  initComponents() {
    $("abbr.timeago").timeago();
    $(".alert").alert();
    $(".dropdown-toggle").dropdown();
    $('[data-toggle="tooltip"]').tooltip();

    // Bind Ctrl+Enter for submit
    $(".cell_comments_new textarea").unbind("keydown");
    $(".cell_comments_new textarea").bind(
      "keydown",
      "ctrl+return",
      function (el) {
        if ($(el.target).val().trim().length > 0) {
          $(el.target).parent().parent().submit();
        }
        return false;
      }
    );

    $(window).off("blur.inactive focus.inactive");
    $(window).on("blur.inactive focus.inactive", this.updateWindowActiveState);

    // Likeable Popover
    return $("a.likeable[data-count!=0]").tooltipster({
      content: "Loading...",
      theme: "tooltipster-shadow",
      side: "bottom",
      maxWidth: 230,
      interactive: true,
      contentAsHTML: true,
      triggerClose: {
        mouseleave: true,
      },
      functionBefore(instance, helper) {
        const $target = $(helper.origin);
        if ($target.data("remote-loaded") === 1) {
          return;
        }

        const likeable_type = $target.data("type");
        const likeable_id = $target.data("id");
        const data = {
          type: likeable_type,
          id: likeable_id,
        };
        return $.ajax({
          url: "/likes",
          data,
          success(html) {
            if (html.length === 0) {
              $target.data("remote-loaded", 1);
              instance.hide();
              return instance.destroy();
            } else {
              instance.content(html);
              return $target.data("remote-loaded", 1);
            }
          },
        });
      },
    });
  },

  initForDesktopView() {
    if (App.mobile !== false) {
      return;
    }
    $("a[rel=twipsy]").tooltip();

    // CommentAble @ 回复功能
    return App.mentionable(".cell_comments_new textarea");
  },

  likeable(e) {
    if (!App.isLogined()) {
      location.href = "/account/sign_in";
      return false;
    }

    const $target = $(e.currentTarget);
    const likeable_type = $target.data("type");
    const likeable_id = $target.data("id");
    let likes_count = parseInt($target.data("count"));

    const $el = $(
      `.likeable[data-type='${likeable_type}'][data-id='${likeable_id}']`
    );

    if ($el.data("state") !== "active") {
      $.ajax({
        url: "/likes",
        type: "POST",
        data: {
          type: likeable_type,
          id: likeable_id,
        },
      });

      likes_count += 1;
      $el.data("count", likes_count);
      this.likeableAsLiked($el);
    } else {
      $.ajax({
        url: `/likes/${likeable_id}`,
        type: "DELETE",
        data: {
          type: likeable_type,
        },
      });
      if (likes_count > 0) {
        likes_count -= 1;
      }
      $el
        .data("state", "")
        .data("count", likes_count)
        .attr("title", "")
        .removeClass("active");
      if (likes_count === 0) {
        $("span", $el).text("");
      } else {
        $("span", $el).text(`${likes_count} ${i18n.t("common.likes")}`);
      }
    }
    $el.data("remote-loaded", 0);
    return false;
  },

  likeableAsLiked(el) {
    const likes_count = el.data("count");
    el.data("state", "active")
      .attr("title", i18n.t("common.unlike"))
      .addClass("active")
      .addClass("animate");
    return $("span", el).text(`${likes_count} ${i18n.t("common.likes")}`);
  },

  initCable() {
    if (!window.notificationChannel && App.isLogined()) {
      return (window.notificationChannel = App.cable.subscriptions.create(
        "NotificationsChannel",
        {
          connected() {
            return this.subscribe();
          },

          received: (data) => {
            return this.receivedNotificationCount(data);
          },

          subscribe() {
            return this.perform("subscribed");
          },
        }
      ));
    }
  },

  receivedNotificationCount(json) {
    // console.log 'receivedNotificationCount', json
    const span = $(".notification-count span");
    const link = $(".notification-count a");
    let new_title = document.title.replace(/^\(\d+\) /, "");
    if (json.count > 0) {
      span.show();
      new_title = `(${json.count}) ${new_title}`;
      const url = App.fixUrlDash(`${App.root_url}${json.content_path}`);
      $.notifier.notify("", json.title, json.content, url);
      link.addClass("new");
    } else {
      span.hide();
      link.removeClass("new");
    }
    span.text(json.count);
    return (document.title = new_title);
  },

  restoreHeaderSearchBox() {
    const $searchInput = $(".header .form-search input");

    if (location.pathname !== "/search") {
      return $searchInput.val("");
    } else {
      const results = new RegExp("[?&]q=([^&#]*)").exec(window.location.href);
      const q = results && decodeURIComponent(results[1]);
      return $searchInput.val(q);
    }
  },

  openHeaderSearchBox(e) {
    $(".header .form-search").addClass("active");
    $(".header .form-search input").focus();
    return false;
  },

  closeHeaderSearchBox(e) {
    $(".header .form-search input").val("");
    $(".header .form-search").removeClass("active");
    return false;
  },

  followUser(e) {
    const btn = $(e.currentTarget);
    const userId = btn.data("id");
    const span = btn.find("span");
    const followerCounter = $(
      `.follow-info .followers[data-login=${userId}] .counter`
    );
    if (btn.hasClass("active")) {
      $.ajax({
        url: `/${userId}/unfollow`,
        type: "POST",
        success(res) {
          if (res.code === 0) {
            btn.removeClass("active");
            span.text("关注");
            return followerCounter.text(res.data.followers_count);
          }
        },
      });
    } else {
      $.ajax({
        url: `/${userId}/follow`,
        type: "POST",
        success(res) {
          if (res.code === 0) {
            btn.addClass("active").attr("title", "");
            span.text("已关注");
            return followerCounter.text(res.data.followers_count);
          }
        },
      });
    }
    return false;
  },

  blockUser(e) {
    const btn = $(e.currentTarget);
    const userId = btn.data("id");
    const span = btn.find("span");
    if (btn.hasClass("active")) {
      $.post(`/${userId}/unblock`);
      btn
        .removeClass("active")
        .attr("title", "忽略后，社区首页列表将不会显示此用户发布的内容。");
      span.text("屏蔽");
    } else {
      $.post(`/${userId}/block`);
      btn.addClass("active").attr("title", "");
      span.text("取消屏蔽");
    }
    return false;
  },

  blockNode(e) {
    const btn = $(e.currentTarget);
    const nodeId = btn.data("id");
    const span = btn.find("span");
    if (btn.hasClass("active")) {
      $.post(`/nodes/${nodeId}/unblock`);
      btn
        .removeClass("active")
        .attr("title", "忽略后，社区首页列表将不会显示这里的内容。");
      span.text("忽略节点");
    } else {
      $.post(`/nodes/${nodeId}/block`);
      btn.addClass("active").attr("title", "");
      span.text("取消屏蔽");
    }
    return false;
  },

  reLoadRucaptchaImage(e) {
    const btn = $(e.currentTarget);
    const img = btn.find("img:first");
    const currentSrc = img.attr("src");
    img.attr("src", currentSrc.split("?")[0] + "?" + new Date().getTime());
    return false;
  },

  updateWindowActiveState(e) {
    const prevType = $(this).data("prevType");

    if (prevType !== e.type) {
      switch (e.type) {
        case "blur":
          this.windowInActive = false;
          break;
        case "focus":
          this.windowInActive = true;
          break;
      }
    }

    return $(this).data("prevType", e.type);
  },

  initInfiniteScroll() {
    return $(".infinite-scroll .item-list").infinitescroll({
      nextSelector: ".pagination .next a",
      navSelector: ".pagination",
      itemSelector: ".topic, .notification-group",
      extraScrollPx: 200,
      bufferPx: 50,
      localMode: true,
      loading: {
        finishedMsg:
          '<div style="text-align: center; padding: 5px;">已到末尾</div>',
        msgText:
          '<div style="text-align: center; padding: 5px;">载入中...</div>',
        img:
          "data:image/gif;base64,R0lGODlhAQABAIAAAP///wAAACH5BAEAAAAALAAAAAABAAEAAAICRAEAOw==",
      },
    });
  },

  initScrollEvent() {
    $(window).off("scroll.navbar-fixed");
    $(window).on("scroll.navbar-fixed", this.toggleNavbarFixed);
    return this.toggleNavbarFixed();
  },

  toggleNavbarFixed(e) {
    const top = $(window).scrollTop();
    if (top >= 50) {
      $(".header.navbar").addClass("navbar-fixed-active");
    } else {
      $(".header.navbar").removeClass("navbar-fixed-active");
    }

    if ($(".navbar-topic-title").length === 0) {
      return;
    }
    if (top >= 50) {
      return $(".header.navbar").addClass("fixed-title");
    } else {
      return $(".header.navbar").removeClass("fixed-title");
    }
  },

  visitTopic(e) {
    const { target, currentTarget } = e;
    if (target.tagName === "A" || target.tagName === "IMG") {
      return;
    }
    currentTarget.querySelector(".title a").click();
  },
});

// Patch for auto dark mode
function getTheme() {
  let preference = $("meta[name='theme']").attr("content");

  if (preference === "auto") {
    if (window.matchMedia("(prefers-color-scheme: dark)").matches) {
      return "dark";
    } else {
      return "light";
    }
  }

  return preference;
}

function switchTheme() {
  let theme = getTheme();
  document.documentElement.setAttribute("data-theme", theme);
}

const mediaDark = window.matchMedia("(prefers-color-scheme: dark)");
mediaDark.addEventListener("change", () => {
  switchTheme();
});

document.addEventListener("turbolinks:load", () => {
  window._appView = new AppView();
  switchTheme();
});

document.addEventListener("turbolinks:click", (event) => {
  if (event.target.getAttribute("href").charAt(0) === "#") {
    return event.preventDefault();
  }
});

switchTheme();
