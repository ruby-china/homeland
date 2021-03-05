# frozen_string_literal: true

class User
  # 用户权限相关
  module Roles
    extend ActiveSupport::Concern

    included do
      enum state: {deleted: -1, member: 1, blocked: 2, vip: 3, hr: 4, maintainer: 90, admin: 99}

      # user.admin?
      define_method :admin? do
        state.to_s == "admin" || Setting.admin_emails.include?(email)
      end
    end

    def wiki_editor?
      admin? || maintainer? || vip?
    end

    # Site editor (replies_count >= 150)
    def site_editor?
      admin? || maintainer? || replies_count >= 100
    end

    # 是否能发帖
    def newbie?
      return false if vip? || hr?
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
        state.to_s == role.to_s
      end
    end

    # 用户的账号类型
    def level
      return "newbie" if newbie?
      state
    end

    def level_name
      I18n.t("activerecord.enums.user.state.#{level}")
    end

    def level_color
      I18n.t("activerecord.enums.user.state_color.#{level}")
    end
  end
end
