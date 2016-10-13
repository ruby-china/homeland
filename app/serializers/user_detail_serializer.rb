# 用户详细信息 API 返回数据结构
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
class UserDetailSerializer < UserSerializer
  attributes :location, :company, :twitter, :website, :bio,
             :tagline, :github, :created_at, :email,
             :topics_count, :replies_count,
             :following_count, :followers_count, :favorites_count,
             :level, :level_name

  def email
    if owner? || object.email_public == true
      object.email
    else
      ''
    end
  end
end
