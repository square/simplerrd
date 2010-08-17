require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe "SimpleRRD::Print" do
  before do
    @p = SimpleRRD::Print.new
    @vd = SimpleRRD::VDef.new
  end

  it "should produce the correct definition" do
    @vd.vname = 'testvdef'
    @p.value = @vd
    @p.text = 'lolwut: %lf'
    @p.definition.should == 'PRINT:testvdef:lolwut\: %lf'
  end
end

describe "SimpleRRD::GPrint" do
  before do
    @p = SimpleRRD::GPrint.new
    @vd = SimpleRRD::VDef.new
  end

  it "should produce the correct definition" do
    @vd.vname = 'testvdef'
    @p.value = @vd
    @p.text = 'lolwut: %lf'
    @p.definition.should == 'GPRINT:testvdef:lolwut\: %lf'
  end
end

describe "SimpleRRD:Comment" do
  it "#definition raise an error unless the text is set" do
    c = SimpleRRD::Comment.new
    lambda { c.definition }.should raise_error
  end

  it "#definition should return the correct definition" do
    c = SimpleRRD::Comment.new(:text => "HELLO there!:.")
    c.definition.should == "COMMENT:HELLO there!\\:."
  end
end

describe "SimpleRRD::Line" do
  before do
    @l = SimpleRRD::Line.new
  end

  it "should (only) allow reasonable numeric widths to be set" do
    @l.width = 3
    @l.width.should == 3
    lambda { @l.width = 'tuna' }.should raise_error
  end

  it "should have a reasonable default width" do
    @l.width.should == 1
  end

  it "should allow you to set the stack option" do
    @l.stack = true
    @l.stack.should == true
  end
  
  it "should default the stack option to false" do
    @l.stack.should == false
  end

  it "#definition should raise an error if no data is set" do
    lambda { @d.definition }.should raise_error
  end

  it "#definition should raise an error if text is set but color == :invisible" do
    @l.color = :invisible
    @l.text  = "emperors clothing line"
    lambda { @d.definition }.should raise_error
  end

  it "should return the correct definition" do
    val = SimpleRRD::Def.new(:vname => 'data')
    SimpleRRD::Line.new(:data => val).definition.should == "LINE1:data\#FFFFFFFF"
    SimpleRRD::Line.new(:data => val, :color => 'DEADBF').definition.should == "LINE1:data\#DEADBFFF"
    SimpleRRD::Line.new(:data => val, :color => :invisible).definition.should == "LINE1:data"
    SimpleRRD::Line.new(:data => val, :width => 5).definition.should == "LINE5:data\#FFFFFFFF"
    SimpleRRD::Line.new(:data => val, :stack => true).definition.should == "LINE1:data\#FFFFFFFF::STACK"
    SimpleRRD::Line.new(:data => val, :text => 'lozenges/sec').definition.should == "LINE1:data\#FFFFFFFF:lozenges/sec"
    SimpleRRD::Line.new(:data => val, :color => "AABBCC", 
                         :width => 10, :text => 'RALPH', 
                        :stack=>true).definition.should == "LINE10:data\#AABBCCFF:RALPH:STACK"
  end
end

describe "SimpleRRD::Area" do
  before do
    @l = SimpleRRD::Area.new
  end

  it "should allow you to set the stack option" do
    @l.stack = true
    @l.stack.should == true
  end
  
  it "should default the stack option to false" do
    @l.stack.should == false
  end

  it "#definition should raise an error if no data is set" do
    lambda { @d.definition }.should raise_error
  end

  it "#definition should raise an error if text is set but color == :invisible" do
    @l.color = :invisible
    @l.text  = "emperors clothing line"
    lambda { @d.definition }.should raise_error
  end

  it "should return the correct definition" do
    val = SimpleRRD::Def.new(:vname => 'data')
    SimpleRRD::Area.new(:data => val).definition.should == "AREA:data\#FFFFFFFF"
    SimpleRRD::Area.new(:data => val, :color => 'DEADBF').definition.should == "AREA:data\#DEADBFFF"
    SimpleRRD::Area.new(:data => val, :color => :invisible).definition.should == "AREA:data"
    SimpleRRD::Area.new(:data => val, :stack => true).definition.should == "AREA:data\#FFFFFFFF::STACK"
    SimpleRRD::Area.new(:data => val, :text => 'lozenges/sec').definition.should == "AREA:data\#FFFFFFFF:lozenges/sec"
    SimpleRRD::Area.new(:data => val, :color => "AABBCC", :text => 'RALPH', 
                        :stack=>true).definition.should == "AREA:data\#AABBCCFF:RALPH:STACK"
  end
end
