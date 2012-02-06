require_relative "../helper"

server = Newman::TestServer
mailer = Newman::TestServer.mailer

noop = Newman::Application.new do
  default do
    skip_response
  end
end
 
describe "Server handling request without responding" do
  it "should not deliver message" do
    mailer.deliver_message(:from => 'tester@test.com',
                           :to   => 'test+noop@test.com')
    server.tick(noop)
    assert_empty mailer.messages
  end
end
