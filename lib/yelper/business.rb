require 'rash'

class Yelper::Business
  attr_accessor :yelper, :hash

  FILL_ATTRIBUTES = [:is_closed, :is_claimed, :reviews]
  def initialize(source_hash={})
    @yelper = source_hash.delete :yelper
    yield self if block_given?
    raise ArgumentError, "Yelper required for #{self.class}" if self.yelper.nil?
    @hash =  Hashie::Rash.new source_hash
    self
  end

  def respond_to?(sym, include_private = false)
    if @hash.respond_to? sym
      true
    elsif FILL_ATTRIBUTES.include? sym
      true
    else
      super
    end
  end

  # On any calls that the Rash can respond to, create the singleton method to proxy calls down
  def method_missing(sym,*args,&block)
    if @hash.respond_to? sym
      define_hash_delegate sym
      self.send sym, *args, &block
    elsif FILL_ATTRIBUTES.include? sym
      @hash = yelper.business @hash.id
      FILL_ATTRIBUTES.each do |attr|
        define_hash_delegate attr
      end
      self.send sym, *args, &block
    else
      super
    end
  end

  private
  def define_hash_delegate(sym)
    define_singleton_method sym do |*args,&block|
        @hash.send sym, *args, &block
    end
  end

end
