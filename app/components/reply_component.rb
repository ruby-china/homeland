# frozen_string_literal: true

class ReplyComponent < ApplicationComponent
  attr_reader :reply

  delegate :timeago, :likeable_tag, to: :helpers

  def initialize(reply:, topic:, reply_counter: 0, show_raw: false)
    @reply = reply
    @topic = topic
    @show_raw = show_raw
    @reply_counter = reply_counter
  end

  def render?
    @reply && @topic
  end

  def show_deleted?
    reply.deleted? && !@show_raw
  end

  def floor
    @floor ||= @reply_counter
  end

  def class_names
    @class_names ||= begin
      class_names = ["reply"]
      class_names << "popular" if reply.popular?
      class_names << "reply-system" if reply.system_event?
      class_names << "reply-deleted" if show_deleted?
      class_names
    end
  end
end
