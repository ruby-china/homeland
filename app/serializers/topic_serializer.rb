# 话题信息
#
# == attributes
# - *id* [Integer] 话题编号
# - *title* [String] 标题
# - *node_name* [String] 节点名称
# - *node_id* [Integer] 节点 ID
# - *excellent* [Boolean] 是否精华
# - *deleted* [Boolean] 是否已删除
# - *replies_count* [Integer] 回帖数量
# - *likes_count* [Integer] 赞数量
# - *last_reply_user_id* [Integer] 最后回复人用户编号
# - *last_reply_user_login* [String] 最后回复者 login
# - *user* {UserSerializer} 最后回复者用户对象
# - *closed_at* [DateTime] 结帖时间，null 表示正常帖子
# - *replied_at* [DateTime] 最后回帖时间
# - *created_at* [DateTime] 创建时间
# - *updated_at* [DateTime] 更新时间
class TopicSerializer < BaseSerializer
  attributes :id, :title, :created_at, :updated_at, :replied_at, :replies_count,
             :node_name, :node_id, :last_reply_user_id, :last_reply_user_login,
             :user, :deleted, :excellent, :abilities, :likes_count, :suggested_at, :closed_at

  def user
    UserSerializer.new(object.user, root: false)
  end

  def deleted
    !object.deleted_at.nil?
  end

  def excellent
    object.excellent == 1
  end
end
