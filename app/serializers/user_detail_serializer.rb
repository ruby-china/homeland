class UserDetailSerializer < UserSerializer  
  attributes :location, :company, :twitter, :website, :bio, 
             :tagline, :github, :created_at, :email
  
  def email
    if owner? || object.email_public == true
      object.email
    else
      ''
    end
  end
end