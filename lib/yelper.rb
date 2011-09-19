require "yelper/version"
require 'yaml'
require 'faraday'
require 'faraday_middleware'

class Yelper

  autoload :Business, 'yelper/business'

  SORT_TYPE = {
      :best => 0,
      :distance => 1,
      :rating => 2
    }

  AUTH_PARAMS = [ :consumer_key, :consumer_secret, :token, :token_secret ]

  attr_accessor :connection

  def initialize( config = {} )

    auth = config.select { |k,v| AUTH_PARAMS.include? k }

    unless AUTH_PARAMS.all? {|param| auth.has_key? param }
      missing = AUTH_PARAMS.reject { |param| auth.has_key? param }
      raise ArgumentError, "Missing authentication parameters #{missing.join ','}"
    end

    @debug = config[:debug]

    @auth = auth
  end

  def connection
    @connection ||= Faraday.new :url => 'http://api.yelp.com/v2' do |b|
      b.use Faraday::Request::OAuth, @auth


      b.use Faraday::Response::Rashify
      b.use Faraday::Response::ParseJson
      b.use Faraday::Response::RaiseError

      b.adapter Faraday.default_adapter

      if @debug 
        b.response :logger
      end
    end
  end

  def search( options )
    res = connection.get do |r|
      r.url '/v2/search', Hash[ options.collect do |k,v|
        case k
        when :category_filter
          v.is_a?(Array) ?  [k, v.join(',')] : [k,v]
        when :ll,:cll
          if v.is_a? Array then
            [k, v.join(',')]
          else
            raise ArgumentError,  "Lat-long pair required for #{k}"
          end
        when :bounds
          if v.is_a? Array and v.length == 2 and v.all? { |a| a.is_a?(Array) and a.length == 2 }  then
            [
              k,
              [v[0].join( ','), v[1].join(',')].join('|')
            ]
          else
            raise ArgumentError, "Pair of lat-long pairs required for bounds"
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

    res.businesses.map! do |b|
      Yelper::Business.new b do |y|
        y.yelper = self
      end
    end

    res
  end

  def business( id ) 
    Yelper::Business.new( connection.get do |r|
        r.url "/v2/business/#{id}"
    end.body) do |y|
      y.yelper = self
    end
  end
end
