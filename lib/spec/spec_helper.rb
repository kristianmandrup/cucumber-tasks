require "bundler"
Bundler.setup(:default, :test)

require 'require-me'
require 'rspec'
require 'rspec/autorun'
require 'hello'

RSpec.configure do |config|
  config.mock_with :mocha
end

