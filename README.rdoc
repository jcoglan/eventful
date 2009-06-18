= Eventful

* http://github.com/jcoglan/eventful

+Eventful+ is a small extension on top of Ruby's +Observable+ module that
implements named events, block listeners and event bubbling. It allows
much more flexible event handling behaviour than is typically allowed
by +Observable+, which requires listeners to be objects that implement
+update+ and provides no simple way of calling subsets of observers based
on event type.


== Installation

  sudo gem install eventful


== Examples

Make a class listenable by mixing +Eventful+ into it:

  class Watcher
    include Eventful
  end

Register event listeners using +on+ with an event name and a block.
Publish events using +fire+ with the event name. The block accepts
the object that published the event, along with any parameters passed
to +fire+.

  w = Watcher.new
  
  w.on(:filechange) { |watcher, path| puts path }
  w.on(:filedelete) { |watcher, path| puts "#{ watcher } deleted #{ path }" }
  
  w.fire(:filechange, '/path/to/file.txt')
  w.fire(:filedelete, '/tmp/pids/event.pid')
  
  # prints...
  # /path/to/file.txt
  # #<Watcher:0xb7b485a4> deleted /tmp/pids/event.pid

The +on+ method returns the +Observer+ object used to represent the listener,
so you can remove it using +delete_observer+.

  obs = w.on(:filechange) { |watcher| ... }
  
  # listener will not fire after this
  w.delete_observer(obs)


=== Method chains instead of blocks

Instead of passing a block, you can add behaviour to objects by chaining
method calls after the +on+ call. For example:

  class Logger
    include Eventful
    
    def print(message)
      puts message
    end
  end
  
  log = Logger.new
  log.on(:receive).print "Received message"
  
  # Calls `log.print "Received message"`
  log.fire(:receive)


=== Events that bubble

When you +fire+ an event, the event 'bubbles' up the type system. What
this means is that you can listen to events on all the instances of a
class just by placing an event listener on the class itself. As above,
the listener is called with the instance that fired the event.

  Logger.on(:receive) { |log, msg| puts "#{ log } :: #{ msg }" }
  
  l1, l2 = Logger.new, Logger.new
  
  l1.fire(:receive, 'The first message')
  l2.fire(:receive, 'Another event')
  
  # prints...
  # #<Logger:0xb7bf103c> :: The first message
  # #<Logger:0xb7bf1028> :: Another event

Method chains can also be used, and they will be replayed on the instance
that initiated the event.

  # Calls `log.print "Received message"`
  
  Logger.on(:receive).print "Received message"
  
  log = Logger.new
  log.fire(:receive)


== License

(The MIT License)

Copyright (c) 2009 James Coglan

Permission is hereby granted, free of charge, to any person obtaining
a copy of this software and associated documentation files (the
'Software'), to deal in the Software without restriction, including
without limitation the rights to use, copy, modify, merge, publish,
distribute, sublicense, and/or sell copies of the Software, and to
permit persons to whom the Software is furnished to do so, subject to
the following conditions:

The above copyright notice and this permission notice shall be
included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED 'AS IS', WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
