require 'json'
require 'oauth2'
require 'securerandom'

module Alijigock
  module Servers
    class OAuthServlet < Base
      # POST /auth
      def route_post
        [:redirect, generate_auth_url]
      end

      def route_get
        token = get_token_by_code(params['code'])
        return [:redirect, '/'] unless token
        identify = fetch_identify(token.token)
        return [:redirect, '/'] if Alijigock.store.owner_id && Alijigock.store.owner_id != identify.user_id
        save_identify(identify, token)
        publish_session
        [:redirect, '/']
      end

      private

      def oauth_client
        @oauth_client ||= OAuth2::Client.new(
          ENV['CLIENT_ID'],
          ENV['CLIENT_SECRET'],
          authorize_url: 'https://slack.com/oauth/authorize',
          token_url: 'https://slack.com/api/oauth.access'
        )
      end

      def generate_auth_url
        oauth_client.auth_code.authorize_url(
          redirect_uri: request_uri.to_s.gsub(/\?.+$/, ''),
          scope: 'identify channels:write'
        )
      end

      def get_token_by_code(code)
        return nil if code.blank?
        oauth_client.auth_code.get_token(
          code,
          redirect_uri: request_uri.to_s.gsub(/\?.+$/, ''),
          scope: 'identify channels:write'
        )
      rescue OAuth2::Error
        nil
      end

      def fetch_identify(token)
        Slack::Web::Client.new(token: token).auth_test
      end

      def save_identify(identify, token)
        Alijigock.store do |store|
          store.owner_id = identify.user_id
          store.owner_name = identify.user
          store.owner_token = token.token
          store.save
        end
      end

      def publish_session
        session_id = SecureRandom.hex
        Alijigock.session_id = session_id
        res['Set-Cookie'] = "#{SESSION_KEY}=#{session_id};Max-Age=3600;"
      end
    end
  end
end
