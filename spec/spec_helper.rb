require 'rubygems'
require 'spork'
require 'rspec'
require 'cachier'
require 'test_application/config/environment'
  
Spork.prefork do
  $LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
  $LOAD_PATH.unshift(File.dirname(__FILE__))
  
  ENV['RAILS_ENV'] = 'test'

  # Requires supporting files with custom matchers and macros, etc,
  # in ./support/ and its subdirectories.
  Dir["#{File.dirname(__FILE__)}/support/**/*.rb"].each {|f| require f}

  RSpec.configure do |config|
    config.before(:each) do
      Rails.cache.clear
    end
  end
end

Spork.each_run do
  # This code will be run each time you run your specs.
end
