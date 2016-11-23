require 'logger'
require 'slack-ruby-client'
require 'hashie'

module Alijigock
  class Bot
    def initialize(token, master_token)
      @access_token = token
      @master_token = master_token
    end

    attr_reader :access_token
    attr_reader :master_token

    def start!
      setup
      init_rtm_client.start!
    rescue => e
      logger.error "#{e.inspect} #{e.backtrace}"
      sleep 5
      retry
    end

    private

    def setup
      fetch_joined_channels.map do |channel|
        refresh_channel(channel)
      end
    end

    def on_message(message)
      case message.subtype
      when 'channel_join'
        on_channel_join(message)
      when 'channel_leave'
        on_channel_leave(message)
      end
    end

    def on_channel_join(message)
      Alijigock.store do |store|
        channel = store.channels.find { |c| c.id == message.channel }
        channel.members.push(message.user)
        store.save
      end
    end

    def on_channel_leave(message)
      channel = fetch_channel(message.channel)
      user = fetch_user(message.user)
      return unless channel && user
      invite(channel, user)
      announce_traitor(channel, user)
    end

    def on_channel_left(message)
      channel = fetch_channel(message.channel)
      return unless channel
      invite(channel, self_info)
      announce_start(channel)
    end

    def on_channel_rename(message)
      # TODO
    end

    def on_channel_archive(message)
      return unless unarchive(message.channel)
      channel = fetch_channel(message.channel)
      invite(channel, self_info)
      refresh_channel(channel)
    end

    def on_channel_unarchive(message)
      # nothing to do
    end

    def on_channel_deleted(message)
      # TODO
    end

    def self_info
      @self_info ||= client.users_info(user: client.auth_test.user_id).user
    end

    def owner_info
      owner_client.users_info(user: owner_client.auth_test.user_id).user
    end

    def fetch_joined_channels
      result = client.channels_list
      return [] unless result.ok
      result.channels.select(&:is_member).map do |c|
        Hashie::Mash.new(id: c.id, name: c.name, members: c.members)
      end
    end

    def fetch_channel(uid)
      result = client.channels_info(channel: uid)
      result.ok ? result.channel : nil
    end

    def fetch_user(uid)
      result = client.users_info(user: uid)
      result.ok ? result.user : nil
    end

    def unarchive(uid)
      result = owner_client.channels_unarchive(channel: uid)
      result.ok
    end

    def invite(channel, user_or_uid)
      uid = user_or_uid.is_a?(Hash) ? user_or_uid.id : user_or_uid
      result = owner_client.channels_invite(channel: channel.id, user: uid)
      result.ok
    rescue Slack::Web::Api::Error => e
      case e.message
      when 'cant_invite_self'
        invite_owner(channel)
      when 'already_in_channel'
        true
      else
        raise e
      end
    end

    def invite_owner(channel)
      result = owner_client.channels_join(name: channel.name)
      result.ok
    rescue Slack::Web::Api::Error => e
      case e.message
      when 'already_in_channel'
        true
      else
        raise e
      end
    end

    def refresh_channel(now_channel)
      Alijigock.store do |store|
        channel = store.channels.find { |c| c.id == now_channel.id }
        if channel
          (channel.members - now_channel.members).each do |uid|
            now_channel.members.push(uid) if invite(channel, uid)
            sleep 0.1 # やさしく
          end

          channel.name = now_channel.name
          channel.members = now_channel.members
        else
          store.channels.push(now_channel)
        end
        store.save
      end
    end

    def announce_traitor(channel, user)
      client.chat_postMessage(
        channel: channel.id,
        text: Alijigock.store.messages.traitor.gsub('<USER_NAME>', "@#{user.name}"),
        parse: 'full',
        as_user: true
      )
    end

    def announce_start(channel)
      client.chat_postMessage(
        channel: channel.id,
        text: Alijigock.store.messages.start,
        parse: 'full',
        as_user: true
      )
    end

    def client
      @client ||= Slack::Web::Client.new(token: access_token)
    end

    def owner_client
      Slack::Web::Client.new(token: Alijigock.store.owner_token)
    end

    def init_rtm_client
      Slack::RealTime::Client.new(token: access_token).tap do |rtm|
        rtm.on(:message, &method(:on_message))
        rtm.on(:channel_left, &method(:on_channel_left))
        rtm.on(:channel_rename, &method(:on_channel_rename))
        rtm.on(:channel_archive, &method(:on_channel_archive))
        rtm.on(:channel_unarchive, &method(:on_channel_unarchive))
        rtm.on(:channel_deleted, &method(:on_channel_deleted))
      end
    end

    def logger
      @logger ||= Logger.new(STDOUT)
    end
  end
end
