# frozen_string_literal: true

class AlertComponent < ApplicationComponent
  def initialize
  end

  def render?
    !!flash.any?
  end

  def alert_class(type)
    type = type.to_s
    type = "alert-success" if type == "notice"
    type = "alert-danger" if type == "alert"

    ["alert alert-dismissible fade show d-flex aic jcsb", type].join(" ")
  end
end
