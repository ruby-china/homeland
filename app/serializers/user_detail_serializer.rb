class UserDetailSerializer < UserSerializer
  attributes :location, :company, :twitter, :website, :bio,
             :tagline, :github, :created_at, :email,
             :topics_count, :replies_count,
             :following_count, :followers_count, :favorites_count,
             :level, :level_name, :admin

  def email
    if owner? || object.email_public == true
      object.email
    else
      ''
    end
  end

  def admin
    object.admin?
  end
end
