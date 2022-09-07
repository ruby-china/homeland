# frozen_string_literal: true

# 增加访问量的功能
module RedisCountable
  extend ActiveSupport::Concern

  class Counter
    attr_reader :key

    def initialize(key, default: 0)
      @key = (key.is_a?(Array) ? key.flatten.join(":") : key).downcase
      redis.setnx(@key, default)
    end

    def redis
      Redis.current
    end

    def incr(by = 1)
      redis.incrby(key, by).to_i
    end

    def value
      redis.get(key).to_i
    end

    def to_s
      value.to_s
    end
    alias_method :to_i, :value

    def nil?
      !redis.exists?(key)
    end
  end

  included do
  end

  class_methods do
    def counter(name, **options)
      ivar_name = :"@#{name}"
      define_method(name) do
        instance_variable_get(ivar_name) ||
          instance_variable_set(ivar_name, Counter.new([self.class.name, id, name], **options))
      end
    end
  end
end
