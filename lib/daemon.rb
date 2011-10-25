# Taken from http://snippets.dzone.com/posts/show/2265

require 'fileutils'

module Daemon
  WorkingDirectory = File.join(File.dirname(__FILE__), '..')

  class Base
    def self.pid_fn
      File.join(WorkingDirectory, "log", "#{name}.pid")
    end
    
    def self.daemonize
      Controller.daemonize(self)
    end
  end
  
  module PidFile
    def self.store(daemon, pid)
      File.open(daemon.pid_fn, 'w') {|f| f << pid}
    end
    
    def self.recall(daemon)
      IO.read(daemon.pid_fn).to_i rescue nil
    end
  end
  
  module Controller
    def self.daemonize(daemon)
      case !ARGV.empty? && ARGV[0]
      when 'start'
        start(daemon)
      when 'stop'
        stop(daemon)
      when 'restart'
        stop(daemon)
        start(daemon)
      else
        puts "Invalid command. Please specify start, stop or restart."
        exit
      end
    end
    
    def self.start(daemon)
      fork do
        Process.setsid
        exit if fork
        PidFile.store(daemon, Process.pid)
        Dir.chdir WorkingDirectory
        File.umask 0000
        STDIN.reopen "/dev/null"
        #STDOUT.reopen "/dev/null", "a"
        STDERR.reopen STDOUT
        trap("TERM") {daemon.stop; exit}
        daemon.start
      end
    end
  
    def self.stop(daemon)
      if !File.file?(daemon.pid_fn)
        puts "Pid file not found. Is the daemon started?"
        exit
      end
      pid = PidFile.recall(daemon)
      FileUtils.rm(daemon.pid_fn)

      begin
        pid && Process.kill("TERM", pid)
      rescue Errno::ESRCH => e
        puts "warning: process #{pid} not found"
      end
    end
  end
end
