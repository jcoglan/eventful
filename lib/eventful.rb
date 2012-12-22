require 'observer'
require 'methodphitamine'

# Adds named event publishing capabilities to the class that includes it.
# Actually composed of three modules: +Observable+ (from Ruby stdlib),
# +ObservableWithBlocks+, and +Eventful+ itself. See +README+ for examples.
module Eventful
  VERSION = '1.0.0'
  
  # The +Observer+ class is used to wrap blocks in an object that implements
  # +update+, so it can be used with +Observable+. It extends <tt>Methodphitamine::It</tt>,
  # meaning it can store any methods called on it and replay them later on any
  # object. This is used to implement blockless event handlers.
  class Observer < Methodphitamine::It
    # Initalize using a block. The block will be called when the observed
    # object sends notifications.
    def initialize(&block)
      super()
      @block = block
    end
    
    # Called by the observed object inside +Observable+ to publish events.
    def update(*args)
      @block.call(*args)
    end
    
    # Patch these back in after Methodphitamine removes them. They are
    # needed for +Observable+ to handle the object properly.
    %w[respond_to? hash send].each do |sym|
      define_method(sym) do |*args|
        Object.instance_method(sym).bind(self).call(*args)
      end
    end
  end
  
  # Extends the +Observable+ module and allows it to accept blocks as observers.
  # This is a distinct module because I often want to do this without using
  # named events.
  module ObservableWithBlocks
    include Observable
    
    # Adds an observer to the object. The observer may be an object implementing
    # +update+, or a block that will be called when the object notifies observers.
    # If a block is passed, we return the wrapping +Observer+ object so it can
    # removed using +delete_observer+.
    def add_observer(*args, &block)
      return super unless block_given?
      observer = Observer.new(&block)
      add_observer(observer)
      observer
    end
  end
  
  # Mix in block observer support
  include ObservableWithBlocks
  
  # Registers a named event handler on the target object that will only fire
  # when the object publishes events with the given name. The handler should
  # be a block that will accept the object that fired the event, along with
  # and data published with the event. Returns a <tt>Methodphitamine::It</tt>
  # instance that will be replayed on the publishing object when the event fires.
  #
  # See +README+ for examples.
  def on(event, &block)
    observer = add_observer do |*args|
      type, data = args[1], [args[0]] + args[2..-1]
      if type == event
        block ||= observer.to_proc
        block.call(*data)
      end
    end
  end
  
  # Fires a named event on the target object. The first argument should be a
  # symbol representing the event name. Any subsequent arguments are passed
  # listeners along with the publishing object. The event bubbles up the type
  # system so that you can listen to all objects of a given type by regsitering
  # listeners on their class.
  def fire(*args)
    return self if defined?(@observer_state) and not @observer_state
    
    receiver = (Hash === args.first) ? args.shift[:receiver] : self
    args = [receiver] + args
    
    changed(true)
    notify_observers(*args)
    changed(true)
    
    args[0] = {:receiver => receiver}
    self.class.ancestors.grep(Eventful).each &it.fire(*args)
    
    self
  end
  
  # Classes that +include+ +Eventful+ are also extended with it, so that event
  # listeners can be registered on a class to fire whenever an instance of
  # that class publishes an event.
  def self.included(base)
    base.extend(self)
  end
  
  # Extend +Eventful+ with itself so you can listen to all eventful objects
  # using <tt>Eventful.on(:eventname) { handle_event() }</tt>.
  extend(self)
  
end

