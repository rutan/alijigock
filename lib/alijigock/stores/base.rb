require 'hashie'
require 'forwardable'

module Alijigock
  module Stores
    class Base
      extend Forwardable

      def initialize
        @parameters = Hashie::Mash.new(default_parameters.deep_merge(load || {}))
      end

      def_delegators :@parameters,
                     :owner_id, :owner_id=, :owner_name, :owner_name=,
                     :owner_token, :owner_token=, :messages, :channels, :channels=
      attr_reader :parameters

      def load
      end

      def save
        puts @parameters.to_json
      end

      private

      def default_parameters
        {
          owner_id: nil,
          owner_name: nil,
          owner_token: nil,
          messages: {
            start: '@channel 円滑な業務のため監視を開始します！',
            traitor: '@channel <USER_NAME>が反逆を試みました！制裁を！'
          },
          channels: []
        }
      end
    end
  end
end
