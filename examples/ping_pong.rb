require_relative "example_helper"

app = PostalService::Application.new do
  to(:tag, "ping") do
    respond(:subject => "pong")
  end

  default do
    respond(:subject => "unknown command")
  end
end

PostalService::Server.run(:config => eval(File.read("config/config.rb")), 
                          :apps   => [app])
