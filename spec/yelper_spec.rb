require './spec/spec_helper.rb'
require 'yelper'

describe Yelper do
  before(:all) do
    @config = {
      :consumer_key => 'consumer_key',
      :consumer_secret => 'consumer_secret',
      :token => 'token',
      :token_secret => 'token_secret'
    }
  end
  describe "For configuration" do
    it "Should raise an ArgumentError with an empty hash" do
      expect {
        Yelper.new({})
      }.to raise_error ArgumentError, /Missing authentication parameters/
    end

    it "Should instantiate with configuration" do
      Yelper.new(@config).should_not be_nil
    end
  end
  describe "For authentication" do
    it "Should raise an error on incorrect auth" do
      expect {
        Yelper.new(@config).business "yelp-san-francisco"
      }.to raise_error Faraday::Error::ClientError, /403/
    end
  end
  describe "After authentication" do
    describe "basic search"
    before(:all) do
      @yelper = Yelper.new YelperHelper.auth_from_env
      @ll = [37.788022,-122.399797]
    end
    it ".business" do
      @yelper.business("yelp-san-francisco").name.should == 'Yelp'
    end

    it ".search :location" do
      res = @yelper.search :location => 'San Francisco'
      res.region.center.should == { "latitude" => 37.75598625000001, "longitude" => -122.4358839 }
    end

    # TODO implement check on returned results, looking for category inclusion in Food/Restaurants
    it ".search :term" do
      res = @yelper.search :term => 'food', :location => 'San Francisco'
      res.businesses.length.should >= 1
    end

    it ".search :limit" do
      res = @yelper.search :term => 'food', :location => 'San Francisco', :limit => 3
      res.businesses.length.should == 3
    end

    it ".search :offset" do
      params = { :term => 'food', :location => 'San Francisco', :limit => 2 }
      original = @yelper.search params
      offset = @yelper.search params.merge( { :limit => 1, :offset => 1 } )
      offset.businesses[0].name.should == original.businesses[1].name
    end

    it ".search :ll" do
      res = @yelper.search :ll => @ll, :term => 'food', :limit => 1
      (res.businesses[0].location.coordinate.latitude - @ll[0]).abs.should < 1
      (res.businesses[0].location.coordinate.longitude - @ll[1]).abs.should < 1
    end

    it ".search :ll :sort => :distance" do
      first = @yelper.search :ll => @ll, :term => 'food', :sort => :distance, :limit => 1
      # Set to min here because Yelp fails with offset > 999, or >39 for distance
      last = @yelper.search :ll => @ll, :term => 'food', :sort => :distance, :limit => 1, :offset  => [first.total,39].min
      first.businesses[0].distance.should < last.businesses[0].distance
    end

    it ".search :category_filter" do
      res = @yelper.search :location => 'San Francisco', :category_filter => 'indpak', :limit => 10
      res.businesses.length.should >= 1
      res.businesses.select do |business|
        business.categories.any? { |c| c[1] == 'indpak' }
      end.length.should == res.businesses.length
    end

    it ".search :radius_filter" do
      res = @yelper.search :ll => @ll, :radius_filter => 200, :sort => :distance
      res.businesses.length.should >= 1
      res.businesses.select do |business|
        business.distance < 200
      end.length.should == res.businesses.length
    end

    it ".search :bounds" do
      bounds = [[37.900000,-122.500000],[37.788022,-122.399797]]
      res = @yelper.search :bounds => '37.900000,-122.500000|37.788022,-122.399797'
      res.businesses.length.should >= 1
      res.businesses.select do |business|
        business.location.coordinate.latitude > bounds[0][0] and
        business.location.coordinate.latitude < bounds[1][0] and
        business.location.coordinate.longitude > bounds[0][1] and
        business.location.coordinate.longitude > bounds[0][1]
      end.length.should == res.businesses.length
    end




  end
end
