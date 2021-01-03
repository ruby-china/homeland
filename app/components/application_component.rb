# frozen_string_literal: true

class ApplicationComponent < ViewComponent::Base
  delegate :user_avatar_tag, :user_name_tag, :icon_tag, :icon_bold_tag, :owner?, :main_app, to: :helpers
end
