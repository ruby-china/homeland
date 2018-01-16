# encoding: utf-8

class TopicPageViewJob < ApplicationJob
  queue_as :topic_page_view

  def perform(topic_id, action = :create)
    case action
    when :create
      TopicPageView.create(topic_id: topic_id)
    when :destroy
      TopicPageView.destroy(topic_id)
    end
  end
end
