# 话题信息
#
# == attributes
# - *id* [Integer] 编号
# - *topic_id* [Integer] 话题编号
# - *deleted* [Boolean] 是否已删除
# - *likes_count* [Integer] 赞数量
# - *user* {UserSerializer} 最后回复者用户对象
# - *created_at* [DateTime] 创建时间
# - *updated_at* [DateTime] 更新时间
class ReplySerializer < BaseSerializer
  attributes :id, :body_html, :created_at, :updated_at, :deleted, :topic_id,
             :user, :likes_count, :abilities

  def user
    UserSerializer.new(object.user, root: false)
  end

  def deleted
    !object.deleted_at.nil?
  end
end
