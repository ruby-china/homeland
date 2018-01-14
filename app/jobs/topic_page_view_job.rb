# encoding: utf-8

class TopicPageViewJob < ApplicationJob
  queue_as :topic_page_view

  def perform(topic_id)
    TopicPageView.create(topic_id: topic_id)
  end
end
