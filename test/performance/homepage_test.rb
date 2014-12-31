require 'test_helper'
require 'rails/performance_test_help'

class HomepageTest < ActionDispatch::PerformanceTest
  # Refer to the documentation for all available options
  # self.profile_options = { runs: 5, metrics: [:wall_time, :memory],
  #                          output: 'tmp/performance', formats: [:flat] }
  self.profile_options = { runs: 5 }

  test "homepage" do
    get '/'
  end
  
  test "/api" do
    get "/api"
  end
end
