require 'rubygems'
require 'bundler/setup'
require 'rack'
require 'rack/test'
require 'rspec'
require 'rack/throttle'
require 'timecop'
require File.dirname(__FILE__) + '/fixtures/fake_app'

Dir[File.dirname(__FILE__) + '/support/**/*.rb'].each {|f| require f}

RSpec.configure do |config|
  config.mock_with :rspec
  config.include Rack::Test::Methods

  def example_target_app
    @target_app ||= Rack::Lint.new(Rack::Test::FakeApp.new)
    @target_app.stub(:call).with(anything).and_return([200, {}, "Hello Throttler!"])
    @target_app
  end
end
