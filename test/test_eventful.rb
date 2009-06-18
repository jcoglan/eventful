require "test/unit"
require "eventful"

class Foo
  include Eventful
end

class TestEventful < Test::Unit::TestCase
  def test_sanity
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
end
