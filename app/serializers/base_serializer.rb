# @abstract
class BaseSerializer < ActiveModel::Serializer
  # 当前 accessToken 对应的用户对此数据的权限
  #
  # @example 表示可修改，不可删除
  #
  #     { update: true, destroy: false }
  #
  # @return update [Boolean] 当前 accessToken 是否有修改权限
  # @return destroy [Boolean] 当前 accessToken 是否有删除权限
  def abilities
    res = { update: can?(:update, object), destroy: can?(:destroy, object) }

    # More actions for Topic
    if object && object.is_a?(Topic)
      %i(ban excellent unexcellent close open).each do |action|
        res.merge!({ action => can?(action, object) })
      end
    end
    res
  end

  protected

    def owner?(obj = nil)
      return false if current_user.blank?

      obj = object if obj.blank?
      if obj.is_a?(User)
        return obj.id == current_user.id
      else
        return obj.user_id == current_user.id
      end
    end

    def cache(keys = [])
      Rails.cache.fetch(['serializer', *keys]) do
        yield
      end
    end

    def current_ability
      @current_ability ||= Ability.new(current_user)
    end

    def can?(*args)
      current_ability.can?(*args)
    end
end
