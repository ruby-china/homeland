# frozen_string_literal: true

class ProfileCardComponent < ApplicationComponent
  delegate :follow_user_tag, to: :helpers

  attr_reader :user

  def initialize(user:)
    @user = user
  end

  def render?
    !!user
  end
end
