# frozen_string_literal: true

class AlertComponent < ApplicationComponent
  def render?
    !!flash.any?
  end

  def alert_class(type)
    type = type.to_s
    type = "alert-success" if type == "notice"
    type = "alert-danger" if type == "alert"

    ["alert alert-dismissible fade show flex items-center md:justify-between", type].join(" ")
  end
end
