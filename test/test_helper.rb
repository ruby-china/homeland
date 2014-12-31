# ENV['RAILS_ENV'] = 'test'
require File.expand_path('../../config/environment', __FILE__)

require 'rails/test_help'

# ActiveRecord::Migration.maintain_test_schema!

class ActionController::TestCase
  include Devise::TestHelpers
end