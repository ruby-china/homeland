# @abstract
class BaseSerializer < ActiveModel::Serializer
  # 当前 accessToken 对应的用户对此数据的权限
  # @readonly
  #
  # == example
  # 表示可修改，不可删除
  #
  #     { update: true, destroy: false }
  #
  # == returns
  # - update [Boolean] 当前 accessToken 是否有修改权限
  # - destroy [Boolean] 当前 accessToken 是否有删除权限
  def abilities
    { update: can?(:update, object), destroy: can?(:destroy, object) }
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
