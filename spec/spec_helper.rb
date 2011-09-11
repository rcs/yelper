require 'simplecov'
SimpleCov.start

require 'yelper'
module YelperHelper
  def self.auth_from_env
    params = Yelper.auth_params
    env_params = Hash[*params.collect { |p| [p, "YELPER_#{p.to_s.upcase}"] }.flatten ]
    auth = Hash[*env_params.collect { |k,v| [k, ENV[v]]}.flatten]
    if auth.values.any? { |v| v.nil? }
      raise ArgumentError, "To test with this library, set environment variables #{env_params.values.join ', '} ( http://www.yelp.com/developers/manage_api_keys )"
    end
    auth.reject {|k,v| v.nil? }
  end
end
