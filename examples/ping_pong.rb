require_relative "../lib/postal_service"

app = PostalService::Application.new do
  to(:tag, "ping") do
    response.subject = "pong"
  end

  default do
    response.subject = "unknown command"
  end
end

PostalService::Server.run(:config => eval(File.read("config.rb")), 
                          :apps   => [app])
