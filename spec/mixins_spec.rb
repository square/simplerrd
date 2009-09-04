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

describe "SimpleRRD::RPNExpressionAttribute" do
	before do
		class TestThree 
			include SimpleRRD::DependencyTracking
			include SimpleRRD::RPNExpressionAttribute

			def allowed_functions
				["x", "xx", "xxx"]
			end
		end

		@t = TestThree.new
	end

	it "should have an rpn_expression that defaults to nil" do
		@t.rpn_expression.should be_nil
	end

	it "should require an Array be passed to #rpn_expression=" do
		lambda { @t.rpn_expression = 1 }.should raise_error
	end

	it "should clear any dependencies before setting the rpn expression" do
		@t.should_receive(:clear_dependencies)
		@t.rpn_expression=[1,2]
	end

	it "should throw an error if a term is not expected" do
		lambda { @t.rpn_expression=[1,Time.now] }.should raise_error
	end

	it "should (only) throw an error if the function is not allowed" do
		lambda { @t.rpn_expression=[1,2,"yyy"] }.should raise_error
		lambda { @t.rpn_expression=[1,2,"xxx"] }.should_not raise_error
	end

	it "should add any ?Def in the expression to the dependencies" do
		d  = SimpleRRD::Def.new
		vd = SimpleRRD::VDef.new
		cd = SimpleRRD::CDef.new

		@t.should_receive(:add_dependency).with(d)
		@t.should_receive(:add_dependency).with(vd)
		@t.should_receive(:add_dependency).with(cd)

		@t.rpn_expression=[1,2,d,vd,cd,'xxx','x','xx']
	end
end

describe "SimpleRRD::TextAttribute" do
	before do
		class TestFour
			include SimpleRRD::TextAttribute
		end

		@t = TestFour.new
	end
	it "should raise an exception if the text string contains \\:" do
		lambda { @t.text='foo\:poo' }.should raise_error
	end

	it "should escape colons with a \\" do
		@t.text = 'foo: boo'
		@t.text == 'foo\: boo'
	end
end

describe "SimpleRRD::ValueAttribute" do
	before do
		class TestFive
			include SimpleRRD::DependencyTracking
			include SimpleRRD::ValueAttribute
		end
		@t = TestFive.new
		@vd = SimpleRRD::VDef.new
	end

	it "should (only) allow a VDef to be stored as the value" do
		@t.value = @vd
		@t.value.should == @vd

		lambda { @t.value = 123 }.should raise_error
	end

	it "should have the vdef in value as a dependency" do
		@t.value = @vd
		@t.dependencies.should include(@vd)
	end
end

describe "SimpleRRD::ColorAttribute" do
	before do
		class TestSix
			include SimpleRRD::ColorAttribute
		end
		@t = TestSix.new
	end

	it "should (only) allow setting reasonable hex RGB values in #color=" do
		@t.color = "AABBCC"
		@t.color.should == "AABBCC"
		lambda { @t.color = "food" }.should raise_error
		lambda { @t.color = "1234567" }.should raise_error
	end

	it "should default to black" do
		@t.color.should == "FFFFFF"
	end

	it "should allow color to be set to :invisible" do
		@t.color = :invisible
		@t.color.should == :invisible
	end
end
