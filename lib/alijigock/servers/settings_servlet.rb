require 'json'

module Alijigock
  module Servers
    class SettingsServlet < Base
      def route_get
        return 401 unless logged_in?
        Alijigock.store.messages
      end

      def route_post
        return 403 unless valid_request_from?
        return 401 unless logged_in?
        Alijigock.store.messages.start = params['start']
        Alijigock.store.messages.traitor = params['traitor']
        Alijigock.store.save
        Alijigock.store.messages
      end
    end
  end
end
