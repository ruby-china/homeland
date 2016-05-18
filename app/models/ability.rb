class Ability
  include CanCan::Ability

  attr_reader :user

  def initialize(u)
    @user = u
    if @user.blank?
      roles_for_anonymous
    elsif @user.has_role?(:admin)
      can :manage, :all
    elsif @user.has_role?(:member)
      roles_for_members
    else
      roles_for_anonymous
    end
  end

  protected

  # 普通会员权限
  def roles_for_members
    roles_for_topics
    roles_for_replies
    roles_for_notes
    roles_for_pages
    roles_for_comments
    roles_for_photos
    roles_for_sites
    basic_read_only
  end

  # 未登录用户权限
  def roles_for_anonymous
    cannot :manage, :all
    basic_read_only
  end

  def roles_for_topics
    unless user.newbie?
      can :create, Topic
    end
    can :favorite, Topic
    can :unfavorite, Topic
    can :follow, Topic
    can :unfollow, Topic
    can :update, Topic do |topic|
      (topic.user_id == user.id)
    end
    can :change_node, Topic do |topic|
      topic.lock_node == false || user.admin?
    end
    can :destroy, Topic do |topic|
      (topic.user_id == user.id) && (topic.replies_count == 0)
    end
  end

  def roles_for_replies
    # 新手用户晚上禁止回帖，防 spam，可在面板设置是否打开
    unless user.newbie? &&
           (Setting.reject_newbie_reply_in_the_evening == 'true') &&
           (Time.zone.now.hour < 9 || Time.zone.now.hour > 22)
      can :create, Reply
    end

    cannot :create, Reply, topic: { :closed? => true }

    can :update, Reply do |reply|
      reply.user_id == user.id
    end

    can :destroy, Reply do |reply|
      reply.user_id == user.id
    end
  end

  def roles_for_notes
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
    can :read, Note do |note|
      note.publish == true
    end
  end

  def roles_for_pages
    if user.has_role?(:wiki_editor)
      can :create, Page
      can :edit, Page do |page|
        page.locked == false
      end
      can :update, Page do |page|
        page.locked == false
      end
    end
  end

  def roles_for_photos
    can :tiny_new, Photo
    can :create, Photo
    can :update, Photo do |photo|
      photo.user_id == photo.id
    end
    can :destroy, Photo do |photo|
      photo.user_id == photo.id
    end
  end

  def roles_for_comments
    can :create, Comment
    can :update, Comment do |comment|
      comment.user_id == comment.id
    end
    can :destroy, Comment do |comment|
      comment.user_id == comment.id
    end
  end

  def roles_for_sites
    if user.has_role?(:site_editor)
      can :create, Site
    end
  end

  def basic_read_only
    can :read, Topic
    can :feed, Topic
    can :node, Topic

    can :read, Reply

    can :read, Page
    can :recent, Page
    can :preview, Page
    can :comments, Page

    can :preview, Note

    can :read, Photo
    can :read, Site
    can :read, Section
    can :read, Node
    can :read, Note do |note|
      note.publish == true
    end
    can :read, Comment
  end
end
