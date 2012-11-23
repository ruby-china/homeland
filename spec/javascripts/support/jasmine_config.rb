Rails.application.assets.append_path File.expand_path('../..', __FILE__)

require 'jasmine/runner_config'

module Jasmine
  class RunnerConfig
    def browser
      # Use chromedriver by default
      ENV["JASMINE_BROWSER"] || 'chrome'
    end
  end
end
