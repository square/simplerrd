require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe "SimpleRRD::ColorScheme" do
  it "#new should expect color values to use" do
    a = SimpleRRD::ColorScheme.new(1,2,3)
  end

  it "should return the colors one by one via #next" do
    a = SimpleRRD::ColorScheme.new(1,2,3)
    a.next.should == 1
    a.next.should == 2
    a.next.should == 3
    a.next.should == 1
  end
end
