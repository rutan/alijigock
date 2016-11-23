require 'optparse'

module Alijigock
  class CLI
    def initialize(argv)
      @argv = argv.dup
      options
    end

    def start!
      Alijigock::Server.new.start
      Bot.new(ENV['SLACK_TOKEN'], ENV['MASTER_TOKEN']).start!
    end

    def options
      @options ||= begin
        result = {}

        opt = OptionParser.new
        opt.on('--dotenv') do
          require 'dotenv'
          Dotenv.load
        end
        result[:argv] = opt.parse(@argv)

        result
      end
    end
  end
end
