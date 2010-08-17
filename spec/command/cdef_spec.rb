require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe "SimpleRRD::CDef" do
  before do
    @c = SimpleRRD::CDef.new
  end

  it "should have an auto-generated vname by default" do
    @c.vname.should match(/obj/)
  end

  it "should (only) allow setting reasonable values for vname" do
    @c.vname = "THOO"
    @c.vname.should == "THOO"
    lambda {@c.vname = "F$K#" }.should raise_error
  end

  it "should (only) allow an array of terms to be passed to rpn_expression=" do
    @c.rpn_expression=[1,2,"*"]
    @c.rpn_expression.should == [1,2,"*"]

    lambda { @c.rpn_expression=123 }.should raise_error
    lambda { @c.rpn_expression=[1,2,"BLOOP"] }.should raise_error
    lambda { @c.rpn_expression=[1,2,Time.now] }.should raise_error
  end

  it "should have 100% test coverage, even including failsafe sanity checks that can't ever happen" do
    @c.instance_eval "@rpn_expression=[Time.now]"
    lambda { @c.expression_string }.should raise_error
  end

  it "should have a dependency on any ?Def in the RPN expression" do
    d = SimpleRRD::Def.new
    @c.rpn_expression = [d,5,"MAX"]
    @c.dependencies.should == [d]

    oc = SimpleRRD::CDef.new
    @c.rpn_expression = [oc,5,"MAX"]
    @c.dependencies.should == [oc]
  end

  it "should raise an exception if #definition is called without a required variable set" do
    lambda { @c.definition }.should raise_error
  end

  it "should return the correct definition when #definition is called" do
    d = SimpleRRD::Def.new
    d.vname = 'ds0'
    @c.vname = 'woot'
    @c.rpn_expression = [d,5,"MAX"]
    @c.definition.should == 'CDEF:woot=ds0,5,MAX'
  end
end
