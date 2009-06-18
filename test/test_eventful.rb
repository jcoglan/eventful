require "test/unit"
require "eventful"

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

class TestEventful < Test::Unit::TestCase
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
end
