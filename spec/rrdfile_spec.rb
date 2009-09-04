require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe "SimpleRRD::RRDFile" do
  it "should take a filename in the constructor" do
    f = SimpleRRD::RRDFile.new("test")
    f.filename.should == "test"
  end
end
