require "spec_helper"

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

describe Eventful do
  before do
    [Foo, Bar, Eventful].each &it.delete_observers
  end
  
  it "fires events" do
    ayes, noes = 0, 0
    f = Foo.new
    f.on(:aye) { |foo, x| ayes += x }
    obs = f.on(:noe) { |foo, x| noes += x }
    
    f.fire(:aye, 1)
    ayes.should == 1
    noes.should == 0
    f.fire(:noe, 3)
    ayes.should == 1
    noes.should == 3
    
    f.delete_observer(obs)
    f.fire(:noe, 3)
    ayes.should == 1
    noes.should == 3
  end
  
  it "allows chaining" do
    f = Foo.new
    f.on(:aye).bump! 2
    f.on(:noe).bump! -1
    
    2.times { f.fire(:aye) }
    f.fire(:noe)
    
    f.count.should == 3
  end
  
  it "bubbles events" do
    bar1, bar2 = Bar.new, Bar.new
    list = []
    Bar.on(:aye) { |r| list << r }
    Eventful.on(:aye) { |r| list << r }
    Eventful.on(:noe) { |r| list << r }
    
    bar1.fire(:aye)
    list.should == [bar1, bar1]
    bar2.fire(:noe)
    list.should == [bar1, bar1, bar2]
    
    Bar.fire(:aye)
    list.should == [bar1, bar1, bar2, Bar]
    Bar.fire(:noe)
    list.should == [bar1, bar1, bar2, Bar]
  end
  
  it "allows chaining on bubble" do
    f1, f2 = Foo.new, Foo.new
    Foo.on(:aye).bump! 5
    f1.fire(:aye)
    f1.count.should == 5
    f2.count.should == 0
    f2.fire(:aye)
    f1.count.should == 5
    f2.count.should == 5
  end
end
