// TopicsController 下所有页面的 JS 功能
window.Topics = {
  topic_id: null,
  user_liked_reply_ids: []
};

window.TopicView = Backbone.View.extend({
  el: "body",
  currentPageImageURLs: [],
  clearHightTimer: null,

  events: {
    "click .navbar .topic-title": "scrollPage",
    "click .reply .btn-reply": "reply",
    "click a.at_floor": "clickAtFloor",
    "click a.follow": "follow",
    "click a.bookmark": "bookmark",
    "click .btn-move-page": "scrollPage",
    "click .notify-updated .update": "updateReplies",
    "click #node-selector .nodes .name a": "nodeSelectorNodeSelected",
    "click .editor-toolbar .reply-to a.close": "unsetReplyTo",
    "tap .topics .topic": "topicRowClick"
  },

  initialize(opts) {
    this.parentView = opts.parentView;

    this.initComponents();
    this.initCableUpdate();
    this.initContentImageZoom();
    this.initCloseWarning();
    this.checkRepliesLikeStatus();
    return this.itemsUpdated();
  },

  // called by new Reply insterted.
  itemsUpdated() {
    this.resetClearReplyHightTimer();
    return this.loadReplyToFloor();
  },

  resetClearReplyHightTimer() {
    clearTimeout(this.clearHightTimer);
    return this.clearHightTimer = setTimeout(() => $(".reply").removeClass("light")
      , 10000);
  },

  // 回复
  reply(e) {
    const _el = $(e.target);
    const reply_to_id = _el.data('id');
    this.setReplyTo(reply_to_id);
    const reply_body = $("#new_reply textarea");
    reply_body.focus();
    return false;
  },

  setReplyTo(id) {
    $('input[name="reply[reply_to_id]"]').val(id);
    const replyEl = $(`.reply[data-id=${id}]`);
    const targetAnchor = replyEl.attr('id');
    const replyToPanel = $(".editor-toolbar .reply-to");
    const userNameEl = replyEl.find("a.user-name:first-child");
    const replyToLink = replyToPanel.find(".user");
    replyToLink.attr("href", `#${targetAnchor}`);
    replyToLink.text(userNameEl.text());
    return replyToPanel.show();
  },

  unsetReplyTo() {
    $('input[name="reply[reply_to_id]"]').val('');
    const replyToPanel = $(".editor-toolbar .reply-to");
    replyToPanel.hide();

    return false;
  },

  clickAtFloor(e) {
    const floor = $(e.target).data('floor');
    return this.gotoFloor(floor);
  },

  // 跳到指定楼。如果楼层在当前页，高亮该层，否则跳转到楼层所在页面并添
  // 加楼层的 anchor。返回楼层 DOM Element 的 jQuery 对象
  //
  // -   floor: 回复的楼层数，从1开始
  gotoFloor(floor) {
    const replyEl = $(`#reply${floor}`);

    this.highlightReply(replyEl);

    return replyEl;
  },

  // 高亮指定楼。取消其它楼的高亮
  //
  // -   replyEl: 需要高亮的 DOM Element，须要 jQuery 对象
  highlightReply(replyEl) {
    $("#replies .reply").removeClass("light");
    return replyEl.addClass("light");
  },

  // 异步更改用户 like 过的回复的 like 按钮的状态
  checkRepliesLikeStatus() {
    return (() => {
      const result = [];
      for (let id of Array.from(Topics.user_liked_reply_ids)) {
        const el = $(`#replies a.likeable[data-id=${id}]`);
        result.push(this.parentView.likeableAsLiked(el));
      }
      return result;
    })();
  },

  // Ajax 回复后的事件
  replyCallback(success, msg) {
    if (msg === '') { return; }
    $("#main .alert-message").remove();
    if (success) {
      $("abbr.timeago", $("#replies .reply").last()).timeago();
      $("abbr.timeago", $("#replies .total")).timeago();
      $("#new_reply textarea").val('');
      $("#preview").text('');
      App.notice(msg, '#reply');
    } else {
      App.alert(msg, '#reply');
    }
    $("#new_reply textarea").focus();
    $('#reply-button').button('reset');
    this.resetClearReplyHightTimer();
    return this.unsetReplyTo();
  },

  // 图片点击增加全屏预览功能
  initContentImageZoom() {
    const exceptClasses = ["emoji", "twemoji", "media-object avatar-16"];
    const imgEls = $(".markdown img");
    for (let el of Array.from(imgEls)) {
      if (exceptClasses.indexOf($(el).attr("class")) === -1) {
        $(el).wrap(`<a href='${$(el).attr("src")}' class='zoom-image' data-action='zoom'></a>`);
      }
    }

    // Bind click event
    if (App.turbolinks || App.mobile) {
      $('a.zoom-image').attr("target", "_blank");
    } else {
      $('a.zoom-image').fluidbox({
        overlayColor: "#FFF",
        closeTrigger: [{
          selector: 'window',
          event: 'scroll'
        }]
      });
    }
    return true;
  },

  preview(body) {
    $("#preview").text("Loading...");

    return $.post("/topics/preview",
      { "body": body },
      data => $("#preview").html(data.body),
      "json");
  },

  hookPreview(switcher, textarea) {
    // put div#preview after textarea
    const self = this;
    const preview_box = $(document.createElement("div")).attr("id", "preview");
    preview_box.addClass("markdown form-control");
    $(textarea).after(preview_box);
    preview_box.hide();

    return $(".preview", switcher).click(function () {
      if ($(this).hasClass("active")) {
        $(this).removeClass("active");
        $(preview_box).hide();
        $(textarea).show();
      } else {
        $(this).addClass("active");
        $(preview_box).show();
        $(textarea).hide();
        $(preview_box).css("height", $(textarea).height());
        self.preview($(textarea).val());
      }
      return false;
    });
  },

  initCloseWarning() {
    let msg;
    const text = $("textarea.closewarning");
    if (text.length === 0) { return false; }
    if (!msg) { msg = "离开本页面将丢失未保存页面!"; }
    $("input[type=submit]").click(() => $(window).unbind("beforeunload"));
    return text.change(function () {
      if (text.val().length > 0) {
        return $(window).bind("beforeunload", function (e) {
          if ($.browser.msie) {
            return e.returnValue = msg;
          } else {
            return msg;
          }
        });
      } else {
        return $(window).unbind("beforeunload");
      }
    });
  },

  bookmark(e) {
    const target = $(e.currentTarget);
    const topic_id = target.data("id");
    const link = $(`.bookmark[data-id='${topic_id}']`);

    if (link.hasClass("active")) {
      $.ajax({
        url: `/topics/${topic_id}/unfavorite`,
        type: "DELETE"
      });
      link.attr("title", "收藏").removeClass("active");
    } else {
      $.post(`/topics/${topic_id}/favorite`);
      link.attr("title", "取消收藏").addClass("active");
    }
    return false;
  },

  follow(e) {
    const target = $(e.currentTarget);
    const topic_id = target.data("id");
    const link = $(`.follow[data-id='${topic_id}']`);

    if (link.hasClass("active")) {
      $.ajax({
        url: `/topics/${topic_id}/unfollow`,
        type: "DELETE"
      });
      link.removeClass("active");
    } else {
      $.ajax({
        url: `/topics/${topic_id}/follow`,
        type: "POST"
      });
      link.addClass("active");
    }
    return false;
  },

  submitTextArea(e) {
    if ($(e.target).val().trim().length > 0) {
      $("form#new_reply").submit();
    }
    return false;
  },

  scrollPage(e) {
    const target = $(e.currentTarget);
    const moveType = target.data('type');
    const opts =
      { scrollTop: 0 };
    if (moveType === 'bottom') {
      opts.scrollTop = $('body').height();
    }
    $("body, html").animate(opts, 300);
    return false;
  },

  initComponents() {
    $("textarea.topic-editor").unbind("keydown.cr");
    $("textarea.topic-editor").bind("keydown.cr", "ctrl+return", el => {
      return this.submitTextArea(el);
    });

    $("textarea.topic-editor").unbind("keydown.mr");
    $("textarea.topic-editor").bind("keydown.mr", "Meta+return", el => {
      return this.submitTextArea(el);
    });

    // also highlight if hash is reply#
    const matchResult = window.location.hash.match(/^#reply\-(\d+)$/);
    if (matchResult != null) {
      this.highlightReply($(`#reply-${matchResult[1]}`).parent());
    }

    this.hookPreview($(".editor-toolbar"), $(".topic-editor"));

    $("body").bind("keydown", "m", el => $('#markdown_help_tip_modal').modal({
      keyboard: true,
      backdrop: true,
      show: true
    }));

    // @ Mention complete
    App.mentionable("textarea", App.scanMentionableLogins($(".reply")));

    // Focus title field in new-topic page
    $("body[data-controller-name='topics'] #topic_title").focus();

    // init editor toolbar
    return window._editor = new Editor();
  },

  initCableUpdate() {
    const self = this;

    if (!Topics.topic_id) {
      return;
    }

    if (!window.repliesChannel) {
      return window.repliesChannel = App.cable.subscriptions.create('RepliesChannel', {
        topicId: null,

        connected() {
          return this.subscribe();
        },

        received: json => {
          if (json.user_id === App.current_user_id) { return false; }
          if (json.action !== 'create') { return false; }
          if (App.windowInActive) {
            return this.updateReplies();
          } else {
            return $(".notify-updated").show();
          }
        },

        subscribe() {
          this.topicId = Topics.topic_id;
          return this.perform('follow', { topic_id: Topics.topic_id });
        },

        unfollow() {
          return this.perform('unfollow');
        }
      }
      );
    } else if (window.repliesChannel.topicId !== Topics.topic_id) {
      window.repliesChannel.unfollow();
      return window.repliesChannel.subscribe();
    }
  },

  updateReplies() {
    const lastId = $("#replies .reply:last").data('id');
    if (!lastId) {
      Turbolinks.visit(location.href);
      return false;
    }
    $.get(`/topics/${Topics.topic_id}/replies.js?last_id=${lastId}`, () => {
      $(".notify-updated").hide();
      return $("#new_reply textarea").focus();
    });
    return false;
  },

  nodeSelectorNodeSelected(e) {
    const el = $(e.currentTarget);
    $("#node-selector").modal('hide');
    $('form input[name="topic[title]"]').focus();
    if ($('form input[name="topic[node_id]"]').length > 0) {
      e.preventDefault();
      const nodeId = el.data('id');
      $('form input[name="topic[node_id]"]').val(nodeId);
      $('#node-selector-button').html(el.text());
      return false;
    } else {
      return true;
    }
  },

  topicRowClick(e) {
    if (!App.turbolinks) {
      return;
    }
    const target = $(e.currentTarget).find(".title a");
    if (e.target.tagName === "A") {
      return true;
    }
    if ($(e.target)[0] === target[0]) {
      return true;
    }

    e.preventDefault();

    $(e.currentTarget).addClass('topic-visited');
    Turbolinks.visit(target.attr('href'));
    return false;
  },

  loadReplyToFloor() {
    return _.each($(".reply-to-block"), el => {
      const replyToId = $(el).data('reply-to-id');
      const floor = $(`#reply-${replyToId}`).data('floor');
      return $(el).find('.reply-floor').text(`\#${floor}`);
    });
  }
});
