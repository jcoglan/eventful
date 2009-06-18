require "test/unit"
require "eventful"
require "set"

class Foo
  include Eventful
  attr_reader :count
  
  def initialize
    @count = 0
  end
  
  def bump!(x = 1)
    @count += x
  end
end

class Bar
  include Eventful
end

class TestEventful < Test::Unit::TestCase
  def setup
    [Foo, Bar, Eventful].each &it.delete_observers
  end
  
  def test_named_events
    ayes, noes = 0, 0
    f = Foo.new
    f.on(:aye) { |foo, x| ayes += x }
    obs = f.on(:noe) { |foo, x| noes += x }
    
    f.fire(:aye, 1)
    assert_equal 1, ayes
    assert_equal 0, noes
    f.fire(:noe, 3)
    assert_equal 1, ayes
    assert_equal 3, noes
    
    f.delete_observer(obs)
    f.fire(:noe, 3)
    assert_equal 1, ayes
    assert_equal 3, noes
  end
  
  def test_chaining
    f = Foo.new
    f.on(:aye).bump! 2
    f.on(:noe).bump! -1
    
    2.times { f.fire(:aye) }
    f.fire(:noe)
    
    assert_equal 3, f.count
  end
  
  def test_bubbling
    bar1, bar2 = Bar.new, Bar.new
    list = []
    Bar.on(:aye) { |r| list << r }
    Eventful.on(:aye) { |r| list << r }
    Eventful.on(:noe) { |r| list << r }
    
    bar1.fire(:aye)
    assert_equal  [bar1, bar1], list
    bar2.fire(:noe)
    assert_equal  [bar1, bar1, bar2], list
    
    Bar.fire(:aye)
    assert_equal  [bar1, bar1, bar2, Bar], list
    Bar.fire(:noe)
    assert_equal  [bar1, bar1, bar2, Bar], list
  end
  
  def test_chaining_on_bubble
    f1, f2 = Foo.new, Foo.new
    Foo.on(:aye).bump! 5
    f1.fire(:aye)
    assert_equal 5, f1.count
    assert_equal 0, f2.count
    f2.fire(:aye)
    assert_equal 5, f1.count
    assert_equal 5, f2.count
  end
end
