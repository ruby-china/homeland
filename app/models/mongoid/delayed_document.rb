# Sidekiq DelayedDocument for Mongoid
module Mongoid
  class DelayedDocument
    include Sidekiq::Worker

    def perform(yml)
      (target, method_name, args) = YAML.load(yml)
      target.send(method_name, *args)
    end
  end
end
