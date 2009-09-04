require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe "SimpleRRD::HashToMethods" do
  before do
    class TestOne
      include SimpleRRD::HashToMethods
    end

    @t = TestOne.new
  end

  it "for every key/value pair in the hash, should call self.key=value" do
    @t.should_receive(:foo=).with('bar')
    @t.should_receive(:baz=).with('pog')
    @t.call_hash_methods(:foo => 'bar', :baz => 'pog')
  end
end

describe "SimpleRRD::DependencyTracking" do
  before do
    class TestTwo
      include SimpleRRD::DependencyTracking
    end

    @leaf_one = TestTwo.new
    @leaf_two = TestTwo.new
    @leaf_three = TestTwo.new
    @two_children = TestTwo.new
    @two_children.add_dependency(@leaf_one)
    @two_children.add_dependency(@leaf_two)
    @three_children = TestTwo.new
    @three_children.add_dependency(@leaf_one)
    @three_children.add_dependency(@leaf_two)
    @three_children.add_dependency(@leaf_three)
    @top = TestTwo.new
    @top.add_dependency(@two_children)
    @top.add_dependency(@three_children)
  end

  it "should report no dependencies by default" do
    @leaf_one.dependencies.should == []
  end

  it "should report immediate dependencies in #dependencies" do
    @top.dependencies.length.should == 2
    @top.dependencies.should include(@two_children)
    @top.dependencies.should include(@three_children)
  end

  it "should report all dependencies in #all_dependencies" do
    all = @top.all_dependencies
    all.should include(@two_children)
    all.should include(@three_children)
    all.should include(@leaf_one)
    all.should include(@leaf_two)
    all.should include(@leaf_three)
    all.length.should == 5 #three leaves, two intermediates
  end
end
