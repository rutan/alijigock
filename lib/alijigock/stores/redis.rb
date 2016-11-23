require 'json'
require 'redis'

module Alijigock
  module Stores
    class Redis < Base
      def load
        JSON.parse(redis.get(KEY_NAME) || '{}')
      rescue
        {}
      end

      def save
        json = parameters.to_json
        redis.set(KEY_NAME, json)
      end

      def redis
        ::Redis.new(url: (ENV['REDIS_URL'] || 'redis://localhost:6379'))
      end

      KEY_NAME = 'alijigock::store'.freeze
    end
  end
end
