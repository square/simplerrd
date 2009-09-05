require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe "SimpleRRD::Def" do
  before do
    @d = SimpleRRD::Def.new
  end
  it "should (only) allow setting an RRDFile via #rrdfile=" do
    f = SimpleRRD::RRDFile.new("/etc/passwd")
    @d.rrdfile = f
    @d.rrdfile.should == f
    lambda { @d.rrdfile = "/etc/passwd" }.should raise_error
  end

  it "should have an auto-generated vname by default" do
    @d.vname.should match(/obj/)
  end

  it "should (only) allow setting reasonable values for vname" do
    @d.vname = "THOO"
    @d.vname.should == "THOO"
    lambda {@d.vname = "F$K#" }.should raise_error
  end
  
  it "should (only) allow reasonable values for ds_name" do
    @d.ds_name = "bobby0"
    @d.ds_name.should == "bobby0"
    lambda {@d.ds_name = "%$" }.should raise_error
  end

  it "should (only) allow setting valid consolidation functions for cf and reduce" do
    SimpleRRD::CONSOLIDATION_FUNCTIONS.each do |fn|
      @d.cf = fn
      @d.cf.should == fn
      @d.reduce = fn
      @d.reduce.should == fn
    end
    lambda { @d.cf = "BLOOP" }.should raise_error
    lambda { @d.reduce = "BLOOP" }.should raise_error
  end

  it "should (only) allow setting positive integers for step" do
    @d.step = 10
    @d.step.should == 10
    lambda { @d.step = "donkey" }.should raise_error
    lambda { @d.step = -10 }.should raise_error
  end

  it "should (only) allow setting Time values for start/end" do
    e = Time.now
    s = e - 3600

    @d.start=s
    @d.end=e
    @d.start.should == s
    @d.end.should == e
    lambda { @d.start="hello" }.should raise_error
    lambda { @d.end="hello" }.should raise_error
  end

  it "should have no dependencies" do
    @d.dependencies.should == []
  end

  it "should raise an exception if #definition is called without a required variable set" do
    file = SimpleRRD::RRDFile.new('file.rrd')

    nofile         = SimpleRRD::Def.new
    nofile.ds_name = 'ds0'
    nofile.cf      = 'MAX'
    lambda { nofile.definition }.should raise_error

    nods         = SimpleRRD::Def.new
    nods.rrdfile = file
    nods.cf      = 'MAX'
    lambda { nods.definition }.should raise_error

    nocf         = SimpleRRD::Def.new
    nocf.ds_name = 'ds0'
    nocf.rrdfile = file
    lambda { nocf.definition }.should raise_error
  end

  it "should return a correct definition in #definition" do
    file = SimpleRRD::RRDFile.new('file.rrd')
    e = Time.now
    s = e - 3600

    @d.rrdfile = file
    @d.ds_name = 'ds0'
    @d.cf      = 'MAX'
    @d.vname   = 'd'

    @d.definition.should == 'DEF:d=file.rrd:ds0:MAX'

    @d.step = 300
    @d.definition.should == 'DEF:d=file.rrd:ds0:MAX:step=300'

    @d.start = s
    @d.definition.should == "DEF:d=file.rrd:ds0:MAX:step=300:start=#{s.to_i}"

    @d.end = e
    @d.definition.should == "DEF:d=file.rrd:ds0:MAX:step=300:start=#{s.to_i}:end=#{e.to_i}"

    @d.reduce = 'AVERAGE'
    @d.definition.should == "DEF:d=file.rrd:ds0:MAX:step=300:start=#{s.to_i}:end=#{e.to_i}:reduce=AVERAGE"
  end
end