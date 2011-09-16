require 'rash'

class Yelper::Business
  attr_accessor :yelper

  FILL_ATTRIBUTES = [:is_closed, :is_claimed, :reviews]
  def initialize(source_hash={})
    @yelper = source_hash.delete :yelper
    yield self if block_given?
    raise ArgumentError, "Yelper required for #{self.class}" if self.yelper.nil?
    @hash =  Hashie::Rash.new source_hash
    self
  end

  def method_missing(sym,*args,&block)
    if @hash.respond_to? sym
      @hash.send sym, *args, &block
    elsif FILL_ATTRIBUTES.include? sym
      @hash = yelper.business @hash.id
      @hash.send sym, *args, &block
    else
      super
    end
  end

end
