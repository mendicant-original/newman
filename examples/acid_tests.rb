require_relative "ping_pong"
require_relative "simple_mailing_list"

require "minitest/autorun"

server = Newman::Server
server.test_mode("config/test.rb")

mailer = server.mailer

describe "Ping Pong" do
  it "responds to an email sent to test+ping@test.com" do
    mailer.deliver_message(:to => "test+ping@test.com")
    server.tick(Newman::Examples::PingPong)
    mailer.messages.first.subject.must_equal("pong")
  end

  it "responds to an email sent to test+bad@test.com" do
    mailer.deliver_message(:to => "test+bad@test.com")
    server.tick(Newman::Examples::PingPong)
    mailer.messages.first.subject.must_equal("unknown command")
  end
end

describe "SimpleList" do
  it "emulates a simple mailing list" do
    mailer.deliver_message(:from => "tester@test.com",
                           :to   => "test@test.com")

    server.tick(Newman::Examples::SimpleList)
    mailer.messages.first.subject.must_equal("You are not subscribed")

    mailer.deliver_message(:from => "tester@test.com",
                           :to   => "test+subscribe@test.com")

    server.tick(Newman::Examples::SimpleList)
    mailer.messages.first.subject.must_equal("SUBSCRIBED!")


    mailer.deliver_message(:from    => "tester@test.com",
                           :to      => "test@test.com",
                           :subject => "WIN!")

    server.tick(Newman::Examples::SimpleList)
    mailer.messages.first.subject.must_equal("WIN!")

    mailer.deliver_message(:from => "tester@test.com",
                           :to   => "test+unsubscribe@test.com")

    server.tick(Newman::Examples::SimpleList)
    mailer.messages.first.subject.must_equal("UNSUBSCRIBED!")
  end

  after do
    if File.exist?(server.settings.application.simplelist_db) 
      File.unlink(server.settings.application.simplelist_db) 
    end
  end
end
