# @class BaseSerializer
# @!method abilities
# 当前 accessToken 对应的用户对此数据的权限
#
# @example 表示可修改，不可删除
#
#     { update: true, destroy: false }
#
# @return update [Boolean] 当前 accessToken 是否有修改权限
# @return destroy [Boolean] 当前 accessToken 是否有删除权限
json.abilities do
  json.update can?(:update, object)
  json.destroy can?(:destroy, object)
  if object && object.is_a?(Topic)
    %i[ban excellent unexcellent close open].each do |action|
      json.set! action, can?(action, object)
    end
  end
end
