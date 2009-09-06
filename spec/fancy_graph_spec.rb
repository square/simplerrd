require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe "SimpleRRD::FancyGraph" do
  before do
    @fg = SimpleRRD::FancyGraph.new
  end

  it "#data should be a convenience method for creating Defs" do
    @fg.data('foo').should be_a(SimpleRRD::Def)
  end

  it "#data should use the 'value' ds by default" do
    d = @fg.data('foo')
    d.ds_name.should == 'value'
  end

  it "#data should use the 'AVERAGE' ds by default" do
    d = @fg.data('foo')
    d.ds_name.should == 'value'
  end
    
  it "should allow setting a color scheme" do
    cs = SimpleRRD::ColorScheme.new(1,2,3)
    @fg.color_scheme = cs
    @fg.color_scheme.should == cs
  end

  it "should use the DEFAULT_COLORS color scheme by default" do
    @fg.color_scheme.should == SimpleRRD::DEFAULT_COLORS
  end

  it "should have a plot method which takes a data set and optional legend" do
    d = @fg.data('foo')
    @fg.plot(d, 'lolz')
  end
end
