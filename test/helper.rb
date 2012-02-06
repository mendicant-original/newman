gem "minitest" 

require "minitest/autorun"
require "purdytest"
require_relative "../lib/newman"

module Newman
  TEST_DIR   =  File.dirname(__FILE__) 

  TestServer =  Newman::Server
  TestServer.test_mode(TEST_DIR + "/settings.rb")
  TestServer.settings.application.simplelist_db = TEST_DIR + "/test.store"

  # TODO: This should probably be moved into test
  TestServer.settings.service.templates_dir = TEST_DIR + "/../examples/views"
end
