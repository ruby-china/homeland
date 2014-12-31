require 'test_helper'
require 'rails/performance_test_help'

class TopicsTest < ActionDispatch::PerformanceTest  
  # Refer to the documentation for all available options
  # self.profile_options = { runs: 5, metrics: [:wall_time, :memory],
  #                          output: 'tmp/performance', formats: [:flat] }
  self.profile_options = { runs: 5 }
  
  def setup
    @topic = Topic.last
    raise "Not have any topic" if @topic.blank?
  end
  
  test "/topics" do
    get '/topics'
  end
  
  test "/topics/:id" do
    get "/topics/#{@topic.id}"
  end
end
