require "test/unit"
require File.expand_path(File.dirname(__FILE__)) + "/../lib/cli_test"
require "tempfile"

class TestCliTest < Test::Unit::TestCase
  class InProcess < CLITest
    
    def not_unix?
      true
    end
  end
  
  def setup
    @tfs = []
  end
  
  def make_tempfile
    tf = Tempfile.new("experiment")
    @tfs.push(tf)
    tf
  end
  
  def teardown
    @tfs.each{|tf| tf.close! }
  end
  
  def test_cli_passes_ARGV
    f = make_tempfile
    f.puts('#!/usr/bin/env ruby')
    f.puts("print ARGV.inspect")
    f.chmod(0x777)
    f.flush
    
    @app = CLITest.new(f.path)
    s, o, e = @app.run("--help")
    assert_equal %w( --help ).inspect, o, "Should be the same STDOUT"
    assert_equal "",                   e, "Should be the same STDERR"
  end
  
  def test_cli_returns_stderr
    f = make_tempfile
    f.puts('#!/usr/bin/env ruby')
    f.puts("$stderr.write ARGV.inspect")
    f.chmod(0x777)
    f.flush
    
    @app = CLITest.new(f.path)
    s, o, e = @app.run("--help")
    assert_equal %w( --help ).inspect, e, "Should be the same STDERR"
  end
  
  def test_cli_passes_exit_status
    f = Tempfile.new("experiment")
    f.puts('#!/usr/bin/env ruby')
    f.puts("exit(12)")
    f.chmod(0x777)
    f.flush
    
    @app = CLITest.new(f.path)
    s, o, e = @app.run("")
    assert_equal 12, s, "Should pass the proper exit status"
  end
  
  def test_cli_passes_exit_status_with_inprocess
    f = Tempfile.new("experiment")
    f.puts('#!/usr/bin/env ruby')
    f.puts("exit(12)")
    f.chmod(0x777)
    f.flush
    
    @app = InProcess.new(f.path)
    s, o, e = @app.run("")
    assert_equal 12, s, "Should pass the proper exit status"
  end
  
  def test_cli_returns_stderr_with_inprocess
    f = make_tempfile
    f.puts('#!/usr/bin/env ruby')
    f.puts("$stderr.write ARGV.inspect")
    f.chmod(0x777)
    f.flush
    
    @app = InProcess.new(f.path)
    s, o, e = @app.run("--help")
    assert_equal %w( --help ).inspect, e, "Should be the same STDERR"
  end
  
  def test_cli_returns_stdout_with_inprocess
    f = make_tempfile
    f.puts('#!/usr/bin/env ruby')
    f.puts("$stdout.write ARGV.inspect")
    f.chmod(0x777)
    f.flush
    
    @app = InProcess.new(f.path)
    s, o, e = @app.run("--help")
    assert_equal %w( --help ).inspect, o, "Should be the same STDOUT"
  end
  
  def test_cli_passes_negative_exit_status
    f = Tempfile.new("experiment")
    f.puts('#!/usr/bin/env ruby')
    f.puts("exit(-12)")
    f.chmod(0x777)
    f.flush
    
    @app = CLITest.new(f.path)
    s, o, e = @app.run("")
    assert_equal -12, s, "Should pass the proper exit status"
  end
end
