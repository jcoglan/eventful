require 'observer'

module Eventful
  VERSION = '0.9.0'
  
  class Observer
    def initialize(&block)
      @block = block
    end
    
    def update(*args)
      @block.call(*args)
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
    add_observer do |*args|
      type, data = args.first, [self] + args[1..-1]
      block.call(*data) if type == event
    end
  end
  
  def fire(*args)
    return if defined?(@observer_state) and not @observer_state
    changed(true)
    notify_observers(*args)
    changed(true)
  end
  
end

