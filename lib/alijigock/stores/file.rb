require 'json'

module Alijigock
  module Stores
    class File < Base
      def load
        return {} unless ::File.exist?(FILE_NAME)
        JSON.parse(::File.read(FILE_NAME))
      rescue
        {}
      end

      def save
        json = parameters.to_json
        ::File.open(FILE_NAME, 'w') do |f|
          f.write json
        end
      end

      FILE_NAME = 'store.json'.freeze
    end
  end
end
