# frozen_string_literal: true

class TopicComponent < ApplicationComponent
  attr_reader :topic, :type

  delegate :topic_excellent_tag, :topic_close_tag, :timeago, to: :helpers

  with_collection_parameter :topic

  def initialize(topic:, type: "normal")
    @topic = topic
    @type = type
  end

  def render?
    !!@topic
  end
end
