require_relative "example_helper"

app = PostalService::Application.new do
  to(:tag, "ping") do
    respond(:subject => "pong")
  end

  default do
    respond(:subject => "unknown command")
  end
end

settings = PostalService::Settings.from_file("config/config.rb")

PostalService::Server.run(:settings => settings, :apps => [app])
