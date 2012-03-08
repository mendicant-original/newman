require "simplecov"
SimpleCov.start

require_relative "integration/acid_tests"
require_relative "integration/skip_response_test"
require_relative "integration/subject_filter_test"
require_relative "integration/template_test"
require_relative "integration/to_filter_test"
