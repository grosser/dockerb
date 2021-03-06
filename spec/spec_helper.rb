require "bundler/setup"
require "dockerb/version"
require "dockerb"
require "tmpdir"

RSpec.configure do |config|
  config.expect_with(:rspec) { |c| c.syntax = :should }
  config.mock_with(:rspec) { |c| c.syntax = :should }
end
