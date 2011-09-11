require "yelper/version"
require 'yaml'
require 'faraday'
require 'faraday_middleware'

class Yelper
  SORT_TYPE = { 
      :best => 0,
      :distance => 1,
      :rating => 2
    }

  def self.auth_params
    [ :consumer_key, :consumer_secret, :token, :token_secret ]
  end
  def initialize( config = {} )

    auth = config.select { |k,v| self.class.auth_params.include? k }

    unless self.class.auth_params.all? {|param| auth.has_key? param }
      missing = self.class.auth_params.reject { |param| auth.has_key? param }
      raise ArgumentError, "Missing authentication parameters #{missing.join ','}"
    end

    @connection = Faraday.new :url => 'http://api.yelp.com/v2' do |b|
      b.use Faraday::Request::OAuth, auth

      b.adapter :net_http

#      b.request :url_encoded
      b.request :json

      b.use Faraday::Response::Rashify
      b.use Faraday::Response::ParseJson
      b.use Faraday::Response::RaiseError

      b.response :logger
    end
  end

  def search( options )
    @connection.get do |r|
      r.url '/v2/search', Hash[ options.collect do |k,v|
        case k
        when :category_filter
          v.is_a?(Array) ?  [k, v.join(',')] : [k,v]
        when :ll,:cll
          if v.is_a? Array then
            [k, v.join(',')]
          else
            throw "Array required for #{k}"
          end
        when :bounds
          if v.is_a? Array and v.length == 2 and v.all? { |a| a.is_a?(Array) and a.length == 2 }  then
            [
              k,
              [v[0].join( ','), v[1].join(',')].join('|')
            ]
          else
            [k,v]
#            throw "Pair of lat-long pairs required for bounds"
          end
        when :sort
          if v.is_a? Symbol
            if self.class::SORT_TYPE.has_key? v
              [k,self.class::SORT_TYPE[v]]
            else
              raise ArgumentError, "Unknown sort type \"#{v}\""
            end
          end
        else 
          [k,v]
        end
      end]
    end.body
  end

  def business( id ) 
    @connection.get do |r|
      r.url "/v2/business/#{id}"
    end.body
  end
end
