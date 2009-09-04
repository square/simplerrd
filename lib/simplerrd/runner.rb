require 'open3'

module SimpleRRD
  class Runner
    def self.run(*cmd)
      data = nil
      err = nil
      Open3.popen3(*cmd) { |stdin, stdout, stderr| stdin.close ; data = stdout.read ; err = stderr.read }
      # unfortunately, popen3 on MRI always returns success in $?
      # (on jruby, $? is what you'd expect)
      # here, we pretend like any output on stderr is evidence of failure.
      raise "Command #{cmd.inspect} failed! stderr was: #{err}" unless err.empty?
      return data.chomp
    end
  end
end
      
