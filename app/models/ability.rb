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
      # Topic
      if !user.newbie?
        can :create, Topic
      end
      can :favorite, Topic
      can :follow, Topic
      can :unfollow,Topic
      can :update, Topic do |topic|
        (topic.user_id == user.id)
      end
      can :destroy, Topic do |topic|
         (topic.user_id == user.id)
      end

      # Reply
      # 新手用户晚上禁止回帖，防 spam，可在面板设置是否打开
      if !(user.newbie? &&
           (SiteConfig.reject_newbie_reply_in_the_evening == 'true') &&
           (Time.zone.now.hour < 9 || Time.zone.now.hour > 22))
        can :create, Reply
      end
      can :update, Reply do |reply|
        reply.user_id == user.id
      end
      can :destroy, Reply do |reply|
        reply.user_id == user.id
      end

      # Note
      can :create, Note
      can :update, Note do |note|
        note.user_id == user.id
      end
      can :destroy, Note do |note|
        note.user_id == user.id
      end
      can :read, Note do |note|
        note.user_id == user.id
      end
      can :read  , Note do |note|
        note.publish == true
      end

      # Wiki
      if user.has_role?(:wiki_editor)
        can :create, Page
        can :edit, Page do |page|
          page.locked == false
        end
        can :update, Page do |page|
          page.locked == false
        end
      end

      # Photo
      can :tiny_new, Photo
      can :create, Photo
      can :update, Photo do |photo|
        photo.user_id == photo.id
      end
      can :destroy, Photo do |photo|
        photo.user_id == photo.id
      end

      # Comment
      can :create, Comment
      can :update, Comment do |comment|
        comment.user_id == comment.id
      end
      can :destroy, Comment do |comment|
        comment.user_id == comment.id
      end

      # Site
      if user.has_role?(:site_editor)
        can :create, Site
      end

      basic_read_only
    else
      # banned or unknown situation
      cannot :manage, :all
      basic_read_only
    end

  end

  protected
    def basic_read_only
      can :read,Topic
      can :feed,Topic
      can :node,Topic

      can :read, Reply

      can :read,  Page
      can :recent, Page
      can :preview, Page
      can :comments, Page

      can :preview, Note

      can :read, Photo
      can :read, Site
      can :read, Section
      can :read, Node
      can :read, Comment
    end
end
