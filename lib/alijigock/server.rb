require 'webrick'

module Alijigock
  class Server
    def initialize
    end

    def start
      Thread.new do
        server.start
      end
    end

    private

    def server
      @server ||= begin
        srv = WEBrick::HTTPServer.new(
          DocumentRoot: File.expand_path('../../../public', __FILE__),
          BindAddress: '0.0.0.0',
          Port: ENV['PORT'] || 5000
        )
        srv.mount('/auth', Alijigock::Servers::OAuthServlet)
        srv.mount('/settings.json', Alijigock::Servers::SettingsServlet)
        srv
      end
    end
  end
end
