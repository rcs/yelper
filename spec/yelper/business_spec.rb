require './spec/spec_helper.rb'
require 'yelper'

describe Yelper::Business do

  before :all do
    @yelper = Yelper.new YelperHelper.auth_from_env
    YelperHelper::add_vcr(@yelper) do |c|
      c.name "business-search"
    end
  end

  describe "creation" do
    it "should error on no yelper" do
      expect {
        Yelper::Business.new
      }.to raise_error ArgumentError, /yelper required/i
    end
    it "should create" do
      Yelper::Business.new(:yelper => @yelper).should_not be_nil
    end
  end

  describe "response encapsulation" do
    before :each do
      @business = @yelper.search(:term => 'food', :location => "San Francisco", :limit => 1).businesses.first
    end

    it "Should return values for the search" do
      @business.url.should_not be_nil
    end

    it "should retrieve values when requested for extended response" do
      @business.reviews.should_not be_nil
    end

    it "shouldn't be able to call" do
      expect {
        @business.not_a_method
      }.to raise_error NoMethodError
    end

    it "should respond to encapsulated methods" do
      @business.respond_to?(:url).should be_true
    end

    it "should respond to extended encapsulated methods" do
      @business.respond_to?(:reviews).should be_true
    end

    it "should not respond to unknown methods" do
      @business.respond_to?(:not_a_method).should be_false
    end

  end

end
