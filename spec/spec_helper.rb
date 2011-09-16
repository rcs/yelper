require 'simplecov'
SimpleCov.start

require 'vcr'
VCR.config do |c|
  c.cassette_library_dir = 'fixtures/vcr_cassettes'
  c.stub_with :faraday
  c.default_cassette_options = { :record => :new_episodes }
end

require 'rspec'
RSpec.configure do |c|
    c.extend VCR::RSpec::Macros
end

require 'yelper'
module YelperHelper
  def self.auth_from_env
    params = Yelper::AUTH_PARAMS
    env_params = Hash[*params.collect { |p| [p, "YELPER_#{p.to_s.upcase}"] }.flatten ]
    auth = Hash[*env_params.collect { |k,v| [k, ENV[v]]}.flatten]
    if auth.values.any? { |v| v.nil? }
      raise ArgumentError, "To test with this library, set environment variables #{env_params.values.join ', '} ( http://www.yelp.com/developers/manage_api_keys )"
    end
    auth.reject {|k,v| v.nil? }
  end

  def self.add_vcr(yelper)
    yelper.connection.builder.insert_before Faraday::Adapter::NetHttp, VCR::Middleware::Faraday do |c,env|
      c.name    env[:url].path.sub(/^\//, '')
      yield c if block_given?
    end
    yelper
  end
end
