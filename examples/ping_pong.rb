require_relative "example_helper"

app = Newman::Application.new do
  to(:tag, "ping") do
    respond(:subject => "pong")
  end

  default do
    respond(:subject => "unknown command")
  end
end

settings = Newman::Settings.from_file("config/config.rb")

server = Newman::Server.new(settings)
server.run(app)
