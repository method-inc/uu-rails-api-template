ENV["RAILS_ENV"] ||= "test"
require "spec_helper"
require File.expand_path("../../config/environment", __FILE__)
require "rspec/rails"

#########################
# Test coverage metrics #
#########################
require "simplecov"
require "simplecov-rcov"

SimpleCov.formatter = SimpleCov::Formatter::MultiFormatter[
  SimpleCov::Formatter::HTMLFormatter,
  SimpleCov::Formatter::RcovFormatter
]

SimpleCov.start do
  add_filter "spec/"
  minimum_coverage(80)
end

# Check for pending migrations before the tests are run
ActiveRecord::Migration.maintain_test_schema!

RSpec.configure do |config|
  # Rails-specific RSpec configurations
end
