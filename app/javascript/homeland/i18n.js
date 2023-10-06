/* eslint-disable */
import i18n from "i18next";
const deepAssign = import("deep-assign");
const metaLocale = document.querySelector("meta[name=locale]");
const lang = ((metaLocale && metaLocale.content) || "en").replace("-", "_");

i18n.init({
  // we init with resources
  resources: {
    en: {
      translation: {
        "common.likes": "likes",
        "common.unlike": "Unlike",
        "common.follow_user": "Follow",
        "common.unfollow_user": "Followed",
        "common.block_user_title":
          "Block this user, you will not see him topics.",
        "common.block_user": "Block",
        "common.unblock_user": "Unblock",
        "common.block_node_title":
          "Block this node, you will not see topics in this node.",
        "common.block_node": "Block node",
        "common.unblock_node": "Unblock node",
        "common.favorite": "Favorite",
        "common.unfavorite": "Unfavorite",
      },
    },
    zh_CN: {
      translation: {
        "common.likes": "个赞",
        "common.unlike": "取消赞",
        "common.follow_user": "关注",
        "common.unfollow_user": "已关注",
        "common.block_user_title":
          "屏蔽后，社区列表将不会出现此用户发布的内容。",
        "common.block_user": "屏蔽",
        "common.unblock_user": "取消屏蔽",
        "common.block_node_title":
          "屏蔽后，社区列表将不会显示此节点有关的内容。",
        "common.block_node": "屏蔽节点",
        "common.unblock_node": "取消节点屏蔽",
        "common.favorite": "收藏",
        "common.unfavorite": "取消收藏",
      },
    },
  },
  debug: false,
  lng: lang,
});
export default i18n;
