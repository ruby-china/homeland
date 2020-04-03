3.4.0
---------

- 正式去掉 `users.verified` 字段 (#1149) 里面已经将它升级到 `state` 字段里面（如你未用升级过 Homeland 3.3.x 请先升级这个版本）；
- 支持在后台设置日期时间的显示时区；
- ActionCable 不再接受匿名用户的连接；
- 生产环境采用紧凑的日志输出；
- 修正某些用户头像错误导致页面 500 的问题;

### 升级注意

- Timezone 需要在后台设置，默认是 UTC，请更新以后进入后台设置时区。

3.3.0
----------

> NOTE: 请使用 [homeland-docker@3.3.x](https://github.com/ruby-china/homeland-docker/tree/3.3.x) 分支

- 全新的插件模式，你可以自由开发插件，并通过后台来管理插件；(#1143)
- 招聘、酷站按新插件模式重构，请注意重新下载插件安装。
- 页面细节有部分微调；
- 后台新增重启功能；
- 每天定时清理一个月前被屏蔽的内容；
- 新增版主权限，以及用户等级（角色）重新调整； (#1149)
- 去掉 LetterAvatar，用固定默认头像代替，还是 LetterAvatar 的风格； (#1151)
- 确保用户的 login, email 是唯一的，并增加 Migration 修正老数据； (#1148)
- 新增 BiliBili 视频的支持; (#1146)


3.2.0
----------

- 允许 social-share-button 在后台配置需要分享的目标;
- 可以在后台配置编辑器的编程语言选项; (#1145)
- Disallow SVG image upload; (#1119)
- Add IP sign up daily limit setting;
- Remove birthday_tag;
- Add upload storage support for Qiuniu (#1086)
- Reload after follow/unfollow user (#1089)
- 屏蔽非图片文件的上传 (#1083)

3.1.0
----------

## 主要更新

- 升级 Rails 5.2;
- 全面迁移 Bootstrap V4，并调整 UI 细节；
- 管理员 NoPoint 功能改为全新方式实现，屏蔽话题的时候不再需要变更节点。
- 简化不必要的配置 key，尽量在管理后台配置 (#1050)
- 增加精华帖连接 (#1032)
- 话题创建增加频率限制，限制间隔时间以及小时内篇数限制。
  - topic_create_limit_interval : 话题创建频率限制，间隔多久（单位: 秒）
  - topic_create_hour_limit_count : 1 小时内，创建话题的数量限制（单位：篇）
- 管理后台新增批量删除某个用户最近 10 篇话题按钮;
- 招聘页新增按城市过滤的功能；
- 实现最新回复的话题列表，所有有新回复的讨论都会往前排列不限时间；

## 问题修复

- 修正 Topic::RateLimit 按小时的限制统计没增加上去的问题;
- 修正 Markdown 图片 //l.ruby-china.org/xxx.jpg 的场景被过滤的问题 (#1039)
- 修复 Team 下的话题列表，排除非当前 team 的内容 (#1034)

## 其他变化

- 新增 `ban_reason_html` 设置项用于代替之前 NoPoint 的节点描述；
- 还原 Notification 的表名称为 "notifications" (#1012)

3.0.0
-----------

## 新特性

- 剥离各类次要功能（Wiki、记事本、头条、招聘）称为 Plugin 模式（对 Docker 使用者无影响），基于源代码开发的用户可以选择性的去掉它们，只需要去掉 `Gemfile` 的依赖就可以了 (#801)
  - [homeland-wiki](https://github.com/ruby-china/homeland-wiki) - Wiki 插件
  - [homeland-jobs](https://github.com/ruby-china/homeland-jobs) - 招聘栏目插件
  - [homeland-note](https://github.com/ruby-china/homeland-note) - 记事本插件
  - [homeland-site](https://github.com/ruby-china/homeland-site) - 酷站插件
  - [homeland-press](https://github.com/ruby-china/homeland-press) - 头条插件
- 插件基础实现，支持自行编写 Homeland 的插件，详见 [PLUGIN_DEV](https://github.com/ruby-china/homeland/blob/master/PLUGIN_DEV.md) 文档。
- 屏蔽话题的时候支持选择／编写屏蔽原因，并在回帖列表里面创建提示 (#909)
- 评论组件现在支持 @ 提及的通知了（#877）
- 文章正文支持 TOC 目录 (#791)
- 移动设备浏览界面对导航栏做了改进，现在可以看到所有的导航链接了。
- 新增 Vimdeo 视频插入的支持

## 改动

- 去掉了“招聘人员”的配置项，管理后台不能在对用户设置此项属性 (#882)
- In Reply To 功能改用楼层编号代替之前无意义的数字编号，并回复楼层显示
- 优化个人收藏的查询方式，同时修正分页数量的问题
- Team 页面的话题列表改为包含所有成员的话题

## homeland-docker 改动

- 去掉 `make upgrade_action_store` 命令

