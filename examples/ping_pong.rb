require_relative "example_helper"

module Newman
  module Examples
    PingPong = Newman::Application.new do
      to(:tag, "ping") do
        respond(:subject => "pong")
      end

      default do
        respond(:subject => "unknown command")
      end
    end
  end
end

if __FILE__ == $PROGRAM_NAME
  Newman::Server.simple(Newman::Examples::PingPong, "config/config.rb")
end
