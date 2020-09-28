import 'bootstrap';
import jQuery from 'jquery';
window.jQuery = jQuery;
window.$ = jQuery;
window.Backbone = require('backbone');
window._ = require('underscore');

import Turbolinks from 'turbolinks';
import TubrolinksPrefetch from 'turbolinks-prefetch'


window.Turbolinks = Turbolinks;
Turbolinks.start();
Turbolinks.setProgressBarDelay(200);
// Increment Turbolinks cache size upto 30
Turbolinks.controller.cache.size = 30
TubrolinksPrefetch.start()

window.Rails = require('@rails/ujs');
Rails.start();

require("pagination");
require("jquery.timeago");
require("jquery.timeago.settings");
require("jquery.hotkeys");
require("jquery.autogrow-textarea");
require("tooltipster.bundle.min");
require("dropzone");
require("jquery.fluidbox.min");
require("jquery.caret");
require("jquery.atwho.min");
require("google_analytics");
require("jquery.infinitescroll.min");
require("jquery.mobile-events");
require("vendor/social-share-button");

import { createConsumer } from '@rails/actioncable';

window.App = {
  turbolinks: false,
  mobile: false,
  locale: 'zh-CN',
  notifier: null,
  current_user_id: null,
  access_token: '',
  asset_url: '',
  twemoji_url: 'https://twemoji.maxcdn.com/',
  root_url: '',
  cable: createConsumer(),

  isLogined() {
    return document.getElementsByName('current-user').length > 0;
  },

  loading() {
    return console.log("loading...");
  },

  fixUrlDash(url) {
    return url.replace(/\/\//g, "/").replace(/:\//, "://");
  },

  // 警告信息显示, to 显示在那个 DOM 前 (可以用 css selector)
  alert(msg, to) {
    $(".alert").remove();
    const html = `<div class='alert alert-warning'><button class='close' data-dismiss='alert'><span aria-hidden='true'>&times;</span></button>${msg}</div>`;
    if (to) {
      return $(to).before(html);
    } else {
      return $("#main").prepend(html);
    }
  },

  // 成功信息显示, to 显示在那个 DOM 前 (可以用 css selector)
  notice(msg, to) {
    $(".alert").remove();
    const html = `<div class='alert alert-success'><button class='close' data-dismiss='alert'><span aria-hidden='true'>&times;</span></button>${msg}</div>`;
    if (to) {
      return $(to).before(html);
    } else {
      return $("#main").prepend(html);
    }
  },

  openUrl(url) {
    return window.open(url);
  },

  // Use this method to redirect so that it can be stubbed in test
  gotoUrl(url) {
    return Turbolinks.visit(url);
  },

  // scan logins in jQuery collection and returns as a object,
  // which key is login, and value is the name.
  scanMentionableLogins(query) {
    const result = [];
    const logins = [];
    for (let e of Array.from(query)) {
      const $e = $(e);
      const item = {
        login: $e.find(".user-name").first().text(),
        name: $e.find(".user-name").first().attr('data-name'),
        avatar_url: $e.find(".avatar img").first().attr("src")
      };

      if (!item.login) { continue; }
      if (!item.name) { continue; }
      if (logins.indexOf(item.login) !== -1) { continue; }

      logins.push(item.login);
      result.push(item);
    }

    console.log(result);
    return _.uniq(result);
  },

  mentionable(el, logins) {
    if (!logins) { logins = []; }
    $(el).atwho({
      at: "@",
      limit: 8,
      searchKey: 'login',
      callbacks: {
        filter(query, data, searchKey) {
          return data;
        },
        sorter(query, items, searchKey) {
          return items;
        },
        remoteFilter(query, callback) {
          const r = new RegExp(`^${query}`);
          // 过滤出本地匹配的数据
          const localMatches = _.filter(logins, u => r.test(u.login) || r.test(u.name));
          // Remote 匹配
          return $.getJSON('/search/users.json', { q: query }, function (data) {
            // 本地的排前面
            for (let u of Array.from(localMatches)) {
              data.unshift(u);
            }
            // 去重复
            data = _.uniq(data, false, item => item.login);
            // 限制数量
            data = _.first(data, 8);
            return callback(data);
          });
        }
      },
      displayTpl: "<li data-value='${login}'><img src='${avatar_url}' height='20' width='20'/> ${login} <small>${name}</small></li>",
      insertTpl: "@${login}"
    }).atwho({
      at: ":",
      limit: 8,
      searchKey: 'code',
      data: window.EMOJI_LIST,
      displayTpl: `<li data-value='\${code}'><img src='${App.twemoji_url}/svg/\${url}.svg' class='twemoji' /> \${code} </li>`,
      insertTpl: "${code}"
    });
    return true;
  }
};
