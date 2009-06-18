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
    
    # Patch this back in after Methodphitamine removes it
    def respond_to?(*args)
      Object.instance_method(:respond_to?).bind(self).call(*args)
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
      type, data = args.first, [self] + args[1..-1]
      if type == event
        block ||= observer.to_proc
        block.call(*data)
      end
    end
  end
  
  def fire(*args)
    return if defined?(@observer_state) and not @observer_state
    changed(true)
    notify_observers(*args)
    changed(true)
  end
  
end

