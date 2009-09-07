require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe "SimpleRRD::Graph" do
  before do
    @g = SimpleRRD::Graph.new
  end

  it "should take a Time value for #start_at= and #end_at=" do
    e = Time.now
    s = e - 3600

    @g.start_at=s
    @g.end_at=e
    @g.start_at.should == s
    @g.end_at.should == e
  end
  
  it "should raise an exception if a non-Time value is passed to them" do
    lambda { @g.start_at="hello" }.should raise_error
    lambda { @g.end_at="hello" }.should raise_error
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

  it "should (only) allow lower_limit and upper_limit to be nil or numeric" do
    @g.lower_limit = nil
    @g.lower_limit.should == nil
    @g.upper_limit = nil
    @g.upper_limit.should == nil
    @g.lower_limit = 10
    @g.lower_limit.should == 10
    @g.upper_limit = 20
    @g.upper_limit.should == 20
    lambda { @g.lower_limit = "ball" }.should raise_error
    lambda { @g.upper_limit = "game" }.should raise_error
  end

  it "should (only) allow setting allowed formats" do
    SimpleRRD::Graph::ALLOWED_FORMATS.each do |f|
      @g.format = f
      @g.format.should == f
    end
    lambda { @g.format = "bread" }.should raise_error
  end

  it "should (only) allow adding RPN Commands to the graph" do
    d = SimpleRRD::Def.new
    @g.add_element(d)
    @g.elements.should include(d)
    lambda { @g.add_element(123) }.should raise_error
  end

  it "should return all dependencies in #dependenceies" do
    d = SimpleRRD::Line.new
    e = SimpleRRD::Area.new
    @g.add_element(d)
    @g.add_element(e)
    d.should_receive(:all_dependencies).and_return([:foo,:bar])
    e.should_receive(:all_dependencies).and_return([:foo,:baz])
    deps = @g.dependencies
    deps.should include(:foo)
    deps.should include(:bar)
    deps.should include(:baz)
    deps.should include(d)
    deps.should include(e)
  end

  it "should generate appropriate commandline flags for the options set" do
    e = Time.now
    s = e - 3600

    @g.start_at = s
    @g.end_at = e
    @g.title = "MY GRAF"
    @g.width = 640
    @g.height = 480
    @g.format = "PNG"

    @g.command_flags.should == ['--start', s.to_i.to_s,
                                '--end',   e.to_i.to_s,
                                '--lower-limit', '0',
                                '--title', "MY GRAF",
                                '--width', '640',
                                '--height', '480',
                                '--full-size-mode',
                                '--imgformat', 'PNG']
  end

  it "should default to 'now' for unspecified end times, '0' for lower limit, and leave all other unspecified values off" do
    @g.command_flags.should == ['--end', 'now', '--lower-limit', '0']
  end

  it "#command_expressions should return the definition of all of the graph's dependencies" do
    a = SimpleRRD::Def.new
    a.should_receive(:definition).and_return('DEF:blah:bloo')

    d = SimpleRRD::Line.new
    d.should_receive(:dependencies).and_return([a])
    d.should_receive(:definition).and_return('LINE:foo:bar')

    @g.add_element(d)

    exprs = @g.command_expressions
    exprs.should include('DEF:blah:bloo')
    exprs.should include('LINE:foo:bar')
  end

  it "should use Runner.run to execute the proper command" do
    e = Time.now
    s = e - 3600

    @g.start_at = s
    @g.end_at = e
    @g.title = "MY GRAF"
    @g.width = 640
    @g.height = 480
    @g.format = "PNG"

    a = SimpleRRD::Def.new
    a.should_receive(:definition).and_return('DEF:blah:bloo')

    d = SimpleRRD::Line.new
    d.should_receive(:dependencies).and_return([a])
    d.should_receive(:definition).and_return('LINE:foo:bar')

    @g.add_element(d)

    expected_command = ['rrdtool', 'graph', '-',
                        '--start', s.to_i.to_s,
                        '--end',   e.to_i.to_s,
                        '--lower-limit', '0',
                        '--title', "MY GRAF",
                        '--width', '640',
                        '--height', '480',
                        '--full-size-mode',
                        '--imgformat', 'PNG',
                        'DEF:blah:bloo',
                        'LINE:foo:bar']
 
    SimpleRRD::Runner.should_receive(:run).with(*expected_command).and_return('ok')

    @g.generate.should == 'ok'
  end

  it "should have a builder method .build" do
    e = Time.now
    s = e - 3600

    a = SimpleRRD::Graph.build do
      start_at s
      end_at   e
      title    "EXAMPLE"
      width    640
      height   480
      format   "SVG"
    end
    
    a.start_at.should == s
    a.end_at.should == e
    a.title.should == 'EXAMPLE'
    a.width.should == 640
    a.height.should == 480
    a.format.should == 'SVG'
  end
end
