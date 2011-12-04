class Ability
  include CanCan::Ability

  def initialize(user)

    if user.blank?
      # not logged in
      cannot :manage, :all
      basic_read_only

    elsif user.has_role?(:admin)
      # admin
      can :manage, :all
    elsif user.has_role?(:member)
      
      can :create, Topic
      can :update, Topic do |topic|
        (topic.user_id == user.id)
      end
      
      can :destroy, Topic do |topic|
         (topic.user_id == user.id)
      end
      
      can :create, Reply 

      
      can :update, Reply do |reply|
        reply.user_id == user.id
      end
      
      
      # Note 
      
      can :read, Note do |note|
        note.user_id == note.id
      end
      
      can :create, Note
      can :update, Note do |note|
        note.user_id == note.id
      end
      can :destroy, Note do |note|
        note.user_id == note.id
      end
      
      # Wiki
      can :read, Page
      can :create, Page
      
      # XXX: Lock page 鎖 update 的話 edit 不知道為什麼不會成功，只好以此法實作
      can :edit, Page do |page|
        page.locked == false
      end
      can :update, Page do |page|
        page.locked == false
      end 
      
      # Photo
      
      can :read, Photo
      can :tiny_new, Photo
      can :update, Photo do |photo|
        photo.user_id == photo.id
      end
      can :destroy, Photo do |photo|
        photo.user_id == photo.id
      end
      
      can :create, Site

      basic_read_only
    else
      # banned or unknown situation
      cannot :manage, :all
      basic_read_only
    end


  end
  
  protected

  def basic_read_only
    can :read,    Topic
    can :feed,    Topic
    can :node,    Topic
    
    can :read  , Note do |note|
       note.publish == true
    end
    
    can :read,  Page
    can :recent, Page
    
    can :read, Photo
    can :read, Site
  end
end

  # Define abilities for the passed in user here. For example:
  #
  #   user ||= User.new # guest user (not logged in)
  #   if user.admin?
  #     can :manage, :all
  #   else
  #     can :read, :all
  #   end
  #
  # The first argument to `can` is the action you are giving the user permission to do.
  # If you pass :manage it will apply to every action. Other common actions here are
  # :read, :create, :update and :destroy.
  #
  # The second argument is the resource the user can perform the action on. If you pass
  # :all it will apply to every resource. Otherwise pass a Ruby class of the resource.
  #
  # The third argument is an optional hash of conditions to further filter the objects.
  # For example, here the user can only update published articles.
  #
  #   can :update, Article, :published => true
  #
  # See the wiki for details: https://github.com/ryanb/cancan/wiki/Defining-Abilities
