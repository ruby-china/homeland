class BaseSerializer < ActiveModel::Serializer
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

  def abilities
    { update: can?(:update, object), destroy: can?(:destroy, object) }
  end
end
