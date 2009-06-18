require 'observer'
require 'rubygems'
require 'methodphitamine'

module Eventful
  VERSION = '0.9.0'
  
  class Observer < Methodphitamine::It
    def initialize(&block)
      super()
      @block = block
    end
    
    def update(*args)
      @block.call(*args)
    end
    
    # Patch these back in after Methodphitamine removes them
    %w[respond_to? hash send].each do |sym|
      define_method(sym) do |*args|
        Object.instance_method(sym).bind(self).call(*args)
      end
    end
  end
  
  module ObservableWithBlocks
    include Observable
    
    def add_observer(*args, &block)
      return super unless block_given?
      observer = Observer.new(&block)
      add_observer(observer)
      observer
    end
  end
  
  include ObservableWithBlocks
  
  def on(event, &block)
    observer = add_observer do |*args|
      type, data = args[1], [args[0]] + args[2..-1]
      if type == event
        block ||= observer.to_proc
        block.call(*data)
      end
    end
  end
  
  def fire(*args)
    return if defined?(@observer_state) and not @observer_state
    
    receiver = (Hash === args.first) ? args.shift[:receiver] : self
    args = [receiver] + args
    
    changed(true)
    notify_observers(*args)
    changed(true)
    
    args[0] = {:receiver => receiver}
    self.class.ancestors.each do |klass|
      klass.fire(*args) if Eventful === klass
    end
  end
  
  def self.included(base)
    base.extend(self)
  end
  
  extend(self)
  
end

