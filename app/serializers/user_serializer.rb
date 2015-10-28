class UserSerializer < BaseSerializer
  attributes :id, :login, :name, :avatar_url

  def avatar_url
    object.avatar? ? object.avatar.url(:large) : object.letter_avatar_url(240)
  end
end
