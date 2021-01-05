# frozen_string_literal: true

class ReplyToComponent < ApplicationComponent
  attr_reader :reply, :show_body

  delegate :markdown, to: :helpers

  def initialize(reply:, topic:, show_body: false)
    @reply = reply
    @topic = topic
    @show_body = show_body
  end

  def reply_to
    reply.reply_to
  end

  def user
    reply_to&.user
  end

  def render?
    !!@reply
  end
end
