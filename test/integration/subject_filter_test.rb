require_relative "../helper"

server = Newman::TestServer
mailer = Newman::TestServer.mailer

app = Newman::Application.new do
  subject :match, "hello" do
    respond(:subject => "HELLOOOOOOOO!")
  end

  default do
    respond(:subject => "No subject, no greeting")
  end
end

describe "subject filter" do
  it "should automatically not match emails without subjects" do
    mailer.deliver_message(:to => "test@test.com")
    server.tick(app)
  end
end
