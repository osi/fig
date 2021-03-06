$LOAD_PATH.unshift(File.dirname(__FILE__))
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))

require 'rubygems'
require 'rspec'

if ENV['COVERAGE']
  require 'simplecov'
  SimpleCov.start
end

require 'fileutils'

require 'fig/command'
require 'fig/figrc'
require 'fig/logging'
require 'fig/repository'

class Popen
  if Fig::OperatingSystem.windows? && ENV['RUBY_VERSION'].include?('1.8.7')
    require 'win32/open3'
    def self.popen(*cmd)
      Open3.popen3(*cmd) { |stdin,stdout,stderr|
        yield stdin, stdout, stderr
      }
    end
  elsif Fig::OperatingSystem.java?
    require 'open3'
    def self.popen(*cmd)
      Open3.popen3(*cmd) { |stdin,stdout,stderr|
        yield stdin, stdout, stderr
      }
    end
  else
    require 'open4'
    def self.popen(*cmd)
      Open4::popen4(*cmd) { |pid, stdin, stdout, stderr|
        yield stdin, stdout, stderr
      }
    end
  end
end

def fig(args, input = nil, no_raise_on_error = false)
  Dir.chdir FIG_SPEC_BASE_DIRECTORY do
    args = "--log-level warn #{args}"
    args = "--no-figrc #{args}"
    args = "--file - #{args}" if input
    out = nil
    err = nil

    Popen.popen("#{Gem::Platform::RUBY} #{FIG_EXE} #{args}") do
      |stdin, stdout, stderr|

      if input
        stdin.puts input
        stdin.close
      end

      err = stderr.read.strip
      out = stdout.read.strip
    end
    result = $CHILD_STATUS

    if not result or result.success? or no_raise_on_error
      return out, err, result.nil? ? 0 : result.exitstatus
    end

    # Common scenario during development is that the fig external process will
    # fail for whatever reason, but the RSpec expectation is checking whether a
    # file was created, etc. meaning that we don't see stdout, stderr, etc. but
    # RSpec's failure message for the expectation, which isn't informative.
    # Throwing an exception that RSpec will catch will correctly integrate the
    # fig output with the rest of the RSpec output.
    fig_failure = "External fig process failed:\n"
    fig_failure << "result: #{result.nil? ? '<nil>' : result}\n"
    fig_failure << "stdout: #{out.nil? ? '<nil>' : out}\n"
    fig_failure << "stderr: #{err.nil? ? '<nil>' : err}\n"

    raise fig_failure
  end
end

Fig::Logging.initialize_post_configuration(nil, 'off', true)

FIG_SPEC_BASE_DIRECTORY =
    File.expand_path(File.dirname(__FILE__) + '/../spec/runtime-work')
FIG_HOME =
    File.expand_path(FIG_SPEC_BASE_DIRECTORY + '/fighome')
FIG_REMOTE_DIR =
    File.expand_path(FIG_SPEC_BASE_DIRECTORY + '/remote')
FIG_BIN =
    File.expand_path(File.dirname(__FILE__) + '/../bin')
FIG_EXE =
    %Q<#{FIG_BIN}/fig>

ENV['FIG_HOME'] = FIG_HOME
ENV['FIG_REMOTE_URL'] = %Q<file://#{FIG_REMOTE_DIR}>
ENV['PATH'] = FIG_BIN + ':' + ENV['PATH']  # To find the correct fig-download

def setup_test_environment()
  FileUtils.mkdir_p(FIG_SPEC_BASE_DIRECTORY)

  FileUtils.mkdir_p(FIG_HOME)

  FileUtils.mkdir_p(FIG_REMOTE_DIR)

  metadata_directory =
    File.join(FIG_REMOTE_DIR, Fig::Repository::METADATA_SUBDIRECTORY)
  FileUtils.mkdir_p(metadata_directory)

  File.open(
    File.join(FIG_REMOTE_DIR, Fig::FigRC::REPOSITORY_CONFIGURATION), 'w'
  ) do
    |handle|
    handle.puts '{}' # Empty Javascript/JSON object
  end

  return
end

def cleanup_test_environment()
  FileUtils.rm_rf(FIG_SPEC_BASE_DIRECTORY)

  return
end

def cleanup_home_and_remote()
  FileUtils.rm_rf(FIG_HOME)
  FileUtils.rm_rf(FIG_REMOTE_DIR)

  return
end
