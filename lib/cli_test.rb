require "stringio"

begin
  require "open3"
rescue LoadError
end

class CLITest
  VERSION = '1.0.1'
  
  def initialize(binary_path)
    @binary_path = File.expand_path(binary_path)
  end
  
  def run(commandline_arguments)
    arguments_as_argv = cli_arguments_to_argv(commandline_arguments)
    (not_unix? || !ruby19?) ? in_process(arguments_as_argv) : in_fork(arguments_as_argv)
  end
  
  def not_unix?
    RUBY_PLATFORM =~ /mswin|jruby/
  end
  
  
  def ruby19?
    !(RUBY_VERSION < "1.9")
  end
    
  # Run the binary under test with passed options, and return [exit_code, stdout_content, stderr_content]
  # There is a limitation however: your app should be using $stdout and $stdeer and NOT their constant
  # equivalents.
  def in_process(commandline_arguments)
    old_stdout, old_stderr, old_argv = $stdout, $stderr, ARGV.dup
    os, es = StringIO.new, StringIO.new
    begin
      $stdout, $stderr, verbosity = os, es, $VERBOSE
      ARGV.replace(commandline_arguments)
      $VERBOSE = false
      
      load(@binary_path)
      return [0, os.string, es.string]
      
    rescue SystemExit => boom # The binary uses exit(), we use that to preserve the output code
      return [boom.status, os.string, es.string]
    rescue Exception => e
      es.puts(e.class)
      es.puts(e.exception)
      return [1, os.string, es.string]
    ensure
      $VERBOSE = verbosity
      ARGV.replace(old_argv)
      $stdout, $stderr = old_stdout, old_stderr
    end
  end
  
  def cli_arguments_to_argv(arguments_string_or_array)
    return arguments_string_or_array if arguments_string_or_array.is_a?(Array)
    arguments_string_or_array.split
  end
  
  # Run the binary under test with passed options, and return [exit_code, stdout_content, stderr_content]
  # There is a limitation however: your app should be using $stdout and $stdeer and NOT their constant
  # equivalents.
  def in_fork(args)
    args.unshift(@binary_path)
    
    if ruby19?
      Open3.popen3(ENV, args.join(' ')) do |stdin, stdout, stderr, wait_thr|
        # Process::Status object returned in Ruby 1.9
        [make_signed(wait_thr.value.exitstatus), stdout.read, stderr.read]
      end
    else
      Open3.popen3(args.join(' ')) do |stdin, stdout, stderr|
        [make_signed($?.to_i), stdout.read, stderr.read]
      end
    end
  end
  
  # yuck!
  def make_signed(retcode)
    ((retcode > 128)) && ((retcode = retcode - 256))
    retcode
  end
end
