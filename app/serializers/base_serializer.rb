class BaseSerializer < ActiveModel::Serializer
  delegate :current_user, to: :scope
  
  def owner?(obj = nil)
    return false if current_user.blank?
    
    obj = object if obj.blank?
    if obj.is_a?(User)
      return obj.id == current_user.id
    else
      return obj.user_id == current_user.id
    end
  end
end