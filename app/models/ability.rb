class Ability
  include CanCan::Ability

  def initialize(user)
    user ||= User.new

    if user.has_role?(:admin)
      can :manage, :all
    elsif user.has_role?(:member)
      apply_member_abilities
    else
      # banned or unknown situation
      # TODO: try write specs for this case
      cannot :manage, :all
      apply_basic_read_only_abilities
    end
  end

protected

  def apply_member_abilities_for_topics
    can :create, Topic
    # TODO: topic could be nil isn't it?
    can_update_topic { |topic| topic.user_id == user.id }
    can_destroy_topic { |topic| topic.user_id == user.id }
  end

  def apply_member_abilities_for_replies
    can :create, Reply
    can_update_reply { |reply| reply.user_id == user.id }
  end

  def apply_member_abilities_for_notes
    can_read_note { |note| note.user_id == user.id }
    can :create, Note
    can_update_note { |note| note.user_id == user.id }
    can_destroy_note { |note| note.user_id == user.id }
  end

  def apply_member_abilities_for_pages
    can :read, Page
    can :create, Page

    # XXX: Lock page 鎖 update 的話 edit 不知道為什麼不會成功，只好以此法實作
    can_edit_page { |page| page.locked == false }
    can_update_page { |page| page.locked == false }
  end

  def apply_member_abilities_for_photos
    can :read, Photo
    can :tiny_new, Photo
    can :create, Photo
    can_update_photo { |photo| photo.user_id == photo.id }
    can_destroy_photo { |photo| photo.user_id == photo.id }
  end

  def apply_member_abilities
    apply_member_abilities_for_topics
    apply_member_abilities_for_replies
    apply_member_abilities_for_notes
    apply_member_abilities_for_pages
    apply_member_abilities_for_photos

    can :create, Site

    apply_basic_read_only_abilities
  end

  def apply_basic_read_only_abilities
    can :read, Topic
    can :feed, Topic
    can :node, Topic

    can_read_note { |note| note.publish == true }

    can :read, Page
    can :recent, Page

    can :read, Photo

    can :read, Site
  end

  def method_missing(method_id, *args, &block)
    if method_id.to_s =~ /can_(\w+)_(\w+)/
      args.unshift $1.to_sym, $2.capitalize
      send(:can, *args, &block)
    else
      super(method_id, *args, &block)
    end
  end
end
