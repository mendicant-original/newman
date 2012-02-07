require_relative "../helper"

describe "subject filter" do
  let(:app) do
    Newman::Application.new do
      subject :match, "hello" do
        respond(:subject => "HELLOOOOOOOO!")
      end

      default do
        respond(:subject => "No subject, no greeting")
      end
    end
  end

  let(:server) { Newman.new_test_server(app) }
  let(:mailer) { server.mailer }

  it "should automatically not match emails without subjects" do
    mailer.deliver_message(:to => "test@test.com")
    server.tick

    mailer.messages.first.subject.must_equal("No subject, no greeting")
  end
end
