require 'webrick'
require 'json'
require 'uri'
require 'securerandom'

module Alijigock
  module Servers
    class Base < WEBrick::HTTPServlet::AbstractServlet
      attr_reader :req, :res

      def do_GET(req, res)
        route(req, res, :route_get)
      end

      def do_POST(req, res)
        route(req, res, :route_post)
      end

      private

      def route(req, res, name)
        @req = req
        @res = res
        body, status = method(name).try(:call)
        if body.nil?
          res.status = 405
        elsif body.is_a?(Integer)
          res.status = body
        elsif body == :redirect
          res.set_redirect(WEBrick::HTTPStatus::SeeOther, status)
        else
          res.status = (status || 200)
          res.content_type = 'application/json; charset=UTF-8'
          res.body = body.to_json
        end
      end

      def logged_in?
        return false unless Alijigock.session_id
        req_session_id = req.cookies.find { |c| c.name == SESSION_KEY }.try(:value)
        Alijigock.session_id == req_session_id
      end

      def params
        @params ||= req.query.map do |k, v|
          [k, v.force_encoding('utf-8')]
        end.to_h
      end

      def request_uri
        req.request_uri
      end

      def valid_request_from?
        from = URI.parse(req.header['x-from'][0] || 'http://invalid-from.example.com/')
        origin = URI.parse(req.header['origin'][0] || 'http://invalid-origin.example.com')
        from.host == origin.host
      end

      SESSION_KEY = '_alijigock_session'.freeze
    end
  end
end
