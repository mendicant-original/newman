require 'tempfile'
require_relative "../helper"

module SkipResponseTests
  module Helpers
    
    def dummy_settings
      f = Tempfile.new("test_environment")
      f.write <<-_____
service.domain           = "test.com"
service.default_sender   = "test@test.com"
service.debug_mode       = true      
      _____
      f.path
    ensure
      f.close if f
    end
    
  end
    
  describe "Server handling request without responding" do
    include Helpers
    
    let(:noop) do
      Newman::Application.new do
        default do
          skip_response
        end
      end
    end

    let(:server) do
      s = Newman::Server.test_mode(dummy_settings)
      s.apps << noop
      s
    end
    
    let(:mailer) { server.mailer }
    
    it "should not deliver message" do
      mailer.deliver_message(:from => 'tester@test.com',
                             :to   => 'test+noop@test.com')
      server.tick
      assert_empty mailer.messages
    end
  end


  describe "Server handling request through multiple apps" do
    include Helpers
    
    let(:noop) do
      Newman::Application.new do
        default do
          skip_response
        end
      end
    end

    let(:app) do
      Newman::Application.new do
        default do
          respond(:subject => "RE: #{request.subject}")
        end
      end 
    end
    
    it "should not deliver message when skip_response app is the last app" do
      server = Newman::Server.test_mode(dummy_settings)
      server.apps << app << noop
      mailer = server.mailer
      mailer.deliver_message( :from => 'tester@test.com',
                              :to   => 'test@test.com',
                              :subject => 'Dear John')
      server.tick
      assert_empty mailer.messages
    end

    it "should deliver message when skip_response app is not the last app" do
      server = Newman::Server.test_mode(dummy_settings)
      server.apps << noop << app
      mailer = server.mailer
      mailer.deliver_message( :from => 'tester@test.com',
                              :to   => 'test@test.com',
                              :subject => 'Dear John')
      server.tick
      msgs = mailer.messages
      
      assert_equal 1, msgs.count
      assert_equal "RE: Dear John", msgs.first.subject
    end
    
  end
  
end