gem "minitest" 

require "minitest/autorun"
require "purdytest"
require_relative "../lib/newman"

module Newman
  TEST_DIR   =  File.dirname(__FILE__) 

  def self.new_test_server(app)
    server = Newman::Server.test_mode(TEST_DIR + "/settings.rb")
    server.apps << app
    server.settings.application.simplelist_db = TEST_DIR + "/test.store"
    server.settings.service.templates_dir = TEST_DIR + "/../examples/views"

    server
  end
end
