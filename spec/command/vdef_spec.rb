require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe "SimpleRRD::VDef" do
  before do
    @v = SimpleRRD::VDef.new
  end

  it "should have an auto-generated vname by default" do
    @v.vname.should match(/obj/)
  end

  it "should (only) allow setting reasonable values for vname" do
    @v.vname = "THOO"
    @v.vname.should == "THOO"
    lambda {@v.vname = "F$K#" }.should raise_error
  end

  it "should (only) allow an array of terms to be passed to rpn_expression=" do
    @v.rpn_expression=[1,2,"MAXIMUM"]
    @v.rpn_expression.should == [1,2,"MAXIMUM"]

    lambda { @v.rpn_expression=123 }.should raise_error
    lambda { @v.rpn_expression=[1,2,"BLOOP"] }.should raise_error
    lambda { @v.rpn_expression=[1,2,Time.now] }.should raise_error
  end

  it "should have 100% test coverage, even including failsafe sanity checks that can't ever happen" do
    @v.instance_eval "@rpn_expression=[Time.now]"
    lambda { @v.expression_string }.should raise_error
  end

  it "should have a dependency on any Def in the RPN expression" do
    d = SimpleRRD::Def.new
    @v.rpn_expression = [d,"MAXIMUM"]
    @v.dependencies.should == [d]
  end

  it "should raise an exception if #definition is called without a required variable set" do
    lambda { @v.definition }.should raise_error
  end

  it "should return the correct definition when #definition is called" do
    d = SimpleRRD::Def.new
    d.vname = 'lolwut'
    @v.rpn_expression=[d,95,'PERCENT']
    @v.vname = 'omgwtf'
    @v.definition.should == "VDEF:omgwtf=lolwut,95,PERCENT"
  end
end
