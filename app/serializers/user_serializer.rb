# 用户 API 返回数据结构
# == attributes
# - *id* [Integer] 用户编号
# - *login* [String] 用户名
# - *name* [String] 用户姓名
# - *avatar_url* [String] 头像 URL
class UserSerializer < BaseSerializer
  attributes :id, :login, :name, :avatar_url

  def avatar_url
    object.avatar? ? object.avatar.url(:large) : object.letter_avatar_url(240)
  end
end
