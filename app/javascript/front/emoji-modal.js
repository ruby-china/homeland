import { EMOJI_LIST, EMOJI_GROUPS } from "./emoji-data";

window.EmojiModalView = Backbone.View.extend({
  className: "emoji-modal modal",

  panels: {},

  events: {
    "click .tab-pane a.emoji": "insertCode",
    "mouseover .tab-pane a.emoji": "preview",
    "click .nav-tabs li a": "changePanel",
  },

  initialize() {
    this.$el.html(`
    <div class="modal-dialog">
      <div class="modal-content">
        <div class="modal-header">
          <ul class="nav nav-tabs">
          </ul>
          <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
        </div>
        <div class="modal-body">
          <div class="tab-content">
          </div>
        </div>
        <div class="modal-footer">
        </div>
      </div>
    </div>
    `);
    for (let group of Array.from(EMOJI_GROUPS)) {
      this.addGroup(group);
    }

    return this.activeFirstPanel();
  },

  activeFirstPanel() {
    this.$el.find(".nav-tabs li a").first().addClass("active");
    const firstGroupName = this.$el
      .find(".nav-tabs li a")
      .first()
      .data("group");
    const tabPane = this.$el.find(`#emoji-group-${firstGroupName}`);
    tabPane.html(this.panels[firstGroupName]);
    return tabPane.addClass("active");
  },

  findEmojiUrlByName(name) {
    const emoji = _.find(EMOJI_LIST, (emoji) => emoji.code === `:${name}:`);
    if (!emoji) {
      return "";
    }
    return `${App.twemoji_url}/svg/${emoji.url}.svg`;
  },

  addGroup(group) {
    this.renderGroupHTML(group);
    if (group.name === "favorites") {
      if (group.icons.length === 0) {
        return false;
      }
    }
    const navTab = `
    <li class="nav-item"><a href="#emoji-group-${group.name}"
          data-group="${group.name}" role="tab" class="nav-link"
          data-bs-toggle ="tab">
        <img src="${this.findEmojiUrlByName(
          group.tabicon
        )}" class="twemoji"></a>
    </li>
    `;
    const navPanel = `
    <div id="emoji-group-${group.name}" class="tab-pane">
    </div>
    `;

    this.$el.find(".nav-tabs").append(navTab);
    return this.$el.find(".tab-content").append(navPanel);
  },

  renderGroupHTML(group) {
    const emojis = [];
    if (group.name === "favorites") {
      group.icons = _.pluck(this.favoriteEmojis(), "code");
    }
    for (let emojiName of Array.from(group.icons)) {
      const url = this.findEmojiUrlByName(emojiName);
      if (!url) {
        continue;
      }
      emojis.push(
        `<a href='#' title='${emojiName}' data-code='${emojiName}' class='emoji'><img src='${url}' class='twemoji'></a>`
      );
    }
    return (this.panels[group.name] = emojis.join(""));
  },

  changePanel(e) {
    const groupName = $(e.currentTarget).data("group");
    return $(`#emoji-group-${groupName}`).html(this.panels[groupName]);
  },

  insertCode(e) {
    const target = $(e.currentTarget);
    const code = target.data("code");
    this.saveFavoritEmoji(code);
    window._editor.insertString(`:${code}: `);
    return false;
  },

  preview(e) {
    const target = $(e.currentTarget);
    const emojiName = target.data("code");
    const code = `:${target.data("code")}: `;
    const html = `<img class='emoji' src='${this.findEmojiUrlByName(
      emojiName
    )}'> ${code}`;
    return this.$el.find(".modal-footer").html(html);
  },

  show() {
    if ($(".emoji-modal").length === 0) {
      $("body").append(this.$el);
    }
    return this.$el.modal("show");
  },

  hide() {
    return this.$el.modal("hide");
  },

  saveFavoritEmoji(code) {
    let emojis = this.favoriteEmojis();
    let emoji = _.find(emojis, (item) => item.code === code);
    if (!emoji) {
      emoji = { code, hits: 0 };
      emojis.push(emoji);
    }
    emoji.hits += 1;
    emojis = _.sortBy(emojis, (item) => 0 - item.hits);
    emojis = _.first(emojis, 100);
    localStorage.setItem("favorite-emojis", JSON.stringify(emojis));
    return this.renderGroupHTML(EMOJI_GROUPS[0]);
  },

  favoriteEmojis() {
    if (!window.localStorage) {
      return [];
    }
    try {
      return JSON.parse(localStorage.getItem("favorite-emojis") || "[]");
    } catch (error) {
      return [];
    }
  },
});
