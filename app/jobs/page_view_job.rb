class PageViewJob < ApplicationJob
  queue_as :page_view

  def perform(*args)
    PageView.create(*args)
  end
end
