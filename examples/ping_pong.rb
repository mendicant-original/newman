require_relative "../lib/postal_service"

app = PostalService::Application.new do
  to(:tag, "ping") do
    respond(:subject => "pong")
  end

  default do
    respond(:subject => "unknown command")
  end
end

PostalService::Server.run(:config => eval(File.read("config.rb")), 
                          :apps   => [app])
