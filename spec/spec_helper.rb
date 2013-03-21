require 'simplecov'
SimpleCov.start

require 'omniauth-samlr'
require 'rack/test'
require 'rexml/document'
require 'rexml/xpath'
require 'base64'

RSpec.configure do |config|
  config.include Rack::Test::Methods
end

def load_xml(filename=:example_response)
  filename = File.expand_path(File.join('..', 'support', "#{filename.to_s}.xml"), __FILE__)
  Base64.encode64(IO.read(filename))
end

def load_file(filename=:example_response)
  filename = File.expand_path(File.join('..', 'support', "#{filename.to_s}"), __FILE__)
  Base64.encode64(IO.read(filename))
end
