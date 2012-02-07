require_relative "../helper"

require_relative "../../examples/ping_pong"
require_relative "../../examples/simple_mailing_list"

describe "Ping Pong" do
  let(:server) { Newman.new_test_server(Newman::Examples::PingPong) }
  let(:mailer) { server.mailer }

  it "responds to an email sent to test+ping@test.com" do
    mailer.deliver_message(:to => "test+ping@test.com")
    server.tick
    mailer.messages.first.subject.must_equal("pong")
  end

  it "responds to an email sent to test+bad@test.com" do
    mailer.deliver_message(:to => "test+bad@test.com")
    server.tick
    mailer.messages.first.subject.must_equal("unknown command")
  end
end

describe "SimpleList" do
  let(:server) { Newman.new_test_server(Newman::Examples::SimpleList) }
  let(:mailer) { server.mailer }

  it "emulates a simple mailing list" do
    mailer.deliver_message(:from    => "tester@test.com",
                           :to      => "test@test.com")

    server.tick

    mailer.messages.first.subject.must_equal("You are not subscribed")

    mailer.deliver_message(:from    => "tester@test.com",
                           :to      => "test+subscribe@test.com",
                           :subject => "subscribe")

    server.tick
    mailer.messages.first.subject.must_equal("SUBSCRIBED!")


    mailer.deliver_message(:from    => "tester@test.com",
                           :to      => "test@test.com",
                           :subject => "WIN!")

    server.tick
    mailer.messages.first.subject.must_equal("WIN!")

    mailer.deliver_message(:from    => "tester@test.com",
                           :to      => "test@test.com",
                           :subject => "unsubscribe")

    server.tick
    mailer.messages.first.subject.must_equal("UNSUBSCRIBED!")
  end

  after do
    if File.exist?(server.settings.application.simplelist_db) 
      File.unlink(server.settings.application.simplelist_db) 
    end
  end
end


# move this when test suite set up



