# frozen_string_literal: true

# 用户 API 返回数据结构
# @class UserSerializer
#
# == attributes
# - *id* [Integer] 用户编号
# - *login* [String] 用户名
# - *name* [String] 用户姓名
# - *avatar_url* [String] 头像 URL

# 用户详细信息 API 返回数据结构
# @class UserDetailSerializer
#
# == attributes
# {include:UserSerializer}
# - *location* [String] 城市
# - *company* [String] 公司名称
# - *github* [String] GitHub ID
# - *twitter* [String] Twitter ID
# - *website* [String] 个人主页 URL
# - *bio* [String] 个人介绍
# - *tagline* [String] 一段话的简单个人介绍
# - *email* [String] Email 地址
# - *topics_count* [Integer] 用户创建的话题数量
# - *replies_count* [Integer] 用户创建的回帖数量
# - *following_count* [Integer] 关注了多少人
# - *followers_count* [Integer] 有多少个关注者
# - *favorites_count* [Integer] 收藏的话题数量
# - *level* [String] 用户级别
# - *level_name* [String] 用户级别(用于显示)
# - *created_at* [DateTime] 注册时间 iso8601 格式
if user
  json.cache! ["v1.1", user, defined?(detail)] do
    json.(user, :id, :login, :name)
    json.avatar_url user.avatar? ? user.avatar.url(:large) : user.letter_avatar_url(240)

    if defined?(detail)
      json.(user, :location, :company, :twitter, :website,
            :tagline, :github, :created_at,
            :topics_count, :replies_count,
            :following_count, :followers_count, :favorites_count,
            :level, :level_name)
      json.bio markdown(user.bio)
      if owner?(user) || user.email_public
        json.email user.email
      else
        json.email ""
      end
    end
    json.partial! "abilities", object: user
  end
end
