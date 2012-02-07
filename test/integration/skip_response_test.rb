require_relative "../helper"

describe "Server handling request without responding" do

  let(:noop) do
    Newman::Application.new do
      default do
        skip_response
      end
    end
  end

  let(:server) { Newman.new_test_server(noop) }
  let(:mailer) { server.mailer }
  
  it "should not deliver message" do
    mailer.deliver_message(:from => 'tester@test.com',
                           :to   => 'test+noop@test.com')
    server.tick
    assert_empty mailer.messages
  end
end
