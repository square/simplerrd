require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe "SimpleRRD::Graph" do
  before do
    @g = SimpleRRD::Graph.new
  end

  it "should take a Time value for #start= and #end=" do
    e = Time.now
    s = e - 3600

    @g.start=s
    @g.end=e
    @g.start.should == s
    @g.end.should == e
  end
  
  it "should raise an exception if a non-Time value is passed to them" do
    lambda { @g.start="hello" }.should raise_error
    lambda { @g.end="hello" }.should raise_error
  end
  
  it "should (only) allow setting of a string as a title" do
    @g.title = "A TITLE"
    @g.title.should == "A TITLE"
    @g.title = 1
    @g.title.should == "1"
  end

  it "should (only) allow setting numeric widths/heights" do
    @g.width = 10
    @g.width.should == 10
    @g.height = 20
    @g.height.should == 20
    lambda { @g.width = "ball" }.should raise_error
    lambda { @g.height = "game" }.should raise_error
  end

  it "should (only) allow setting allowed formats" do
    SimpleRRD::Graph::ALLOWED_FORMATS.each do |f|
      @g.format = f
      @g.format.should == f
    end
    lambda { @g.format = "bread" }.should raise_error
  end

  it "should generate appropriate commandline flags for the options set" do
    e = Time.now
    s = e - 3600

    @g.start = s
    @g.end = e
    @g.title = "MY GRAF"
    @g.width = 640
    @g.height = 480
    @g.format = "PNG"

    @g.command_flags.should == ['--start', s.to_i.to_s,
                                '--end',   e.to_i.to_s,
                                '--title', "MY GRAF",
                                '--width', '640',
                                '--height', '480',
                                '--imgformat', 'PNG']
  end

  it "should default to 'now' for unspecified end times, and leave all other unspecified values off" do
    @g.command_flags.should == ['--end', 'now']
  end

  it "should allow setting the various options through the constructor hash" do
    n = SimpleRRD::Graph.new(:title => "TITLE", :width => 100)
    n.title.should == "TITLE"
    n.width.should == 100
  end
end
