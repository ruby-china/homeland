# frozen_string_literal: true

class User
  # 用户权限相关
  module Roles
    extend ActiveSupport::Concern

    included do
      enum state: { deleted: -1, member: 1, blocked: 2, vip: 3, hr: 4, maintainer: 90, admin: 99 }

      # user.admin?
      define_method :admin? do
        self.state.to_s == "admin" || Setting.admin_emails.include?(self.email)
      end
    end

    # 是否有 Wiki 维护权限
    def wiki_editor?
      self.admin? || self.maintainer? || self.vip?
    end

    # 是否可以发专栏
    def column_editor?
      # 开关为关时，不能发专栏
      return false if Setting.column_enabled.blank?
      # 只有白名单用户可以发专栏
      return false if Setting.column_user_white_list.nil?
      if Setting.column_user_white_list.split(Setting::SEPARATOR_REGEXP).include? login
        return true
      end
    end

    # 回帖大于 150 的才有酷站的发布权限
    def site_editor?
      self.admin? || self.maintainer? || replies_count >= 100
    end

    # 是否能发帖
    def newbie?
      return false if self.vip? || self.hr?
      t = Setting.newbie_limit_time.to_i
      return false if t == 0
      created_at > t.seconds.ago
    end

    # used in Plugin
    def roles?(role)
      case role
      when :wiki_editor then wiki_editor?
      when :site_editor then site_editor?
      else
        self.state.to_s == role.to_s
      end
    end

    # 用户的账号类型
    def level
      return "newbie" if self.newbie?
      self.state
    end

    def level_name
      I18n.t("activerecord.enums.user.state.#{self.level}")
    end

    def level_color
      I18n.t("activerecord.enums.user.state_color.#{self.level}")
    end
  end
end
