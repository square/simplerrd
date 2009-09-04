require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe "SimpleRRD::Runner" do
  it "should run commands passed to Runner.run and return the output" do
    SimpleRRD::Runner.run("echo", "hi").should == "hi"
  end

  it "should not invoke a shell to run the commands" do
    SimpleRRD::Runner.run("echo", "/*").should == "/*" # a shell would have interpreted the glob
  end

  it "should raise an exception if anything is written to stdout" do
    lambda {
      SimpleRRD::Runner.run(File.dirname(__FILE__) + '/misc/echo_to_stderr', "test")
    }.should raise_error
  end
end
