require 'optparse'

require 'fig/package'
require 'fig/packagedescriptor'
require 'fig/package/archive'
require 'fig/package/include'
require 'fig/package/path'
require 'fig/package/resource'
require 'fig/package/set'

module Fig; end

# Command-line processing.
class Fig::Options
  USAGE = <<-EOF

Usage:

  fig [...] [<descriptor>] [--update | --update-if-missing] [-- <command>]

  fig {--publish | --publish-local} <descriptor>
      [--resource <fullpath>]
      [--include <package name/version>]
      [--force]
      [--archive <path>]
      [...]

  fig --clean <descriptor> [...]

  fig --get <VAR>                                               [<descriptor>] [...]
  fig --list-configs                                            [<descriptor>] [...]
  fig {--list-local | --list-remote} [...]

  fig {--version | --help}

Not yet implemented:
  fig {--list-dependencies | --list-dependencies-all-configs}   [<descriptor>] [...]
  fig {--list-all-variables | --list-all-variables-all-configs} [<descriptor>] [...]

A <descriptor> looks like <package name>[:<config>][/<version>] e.g. "foo",
"foo/1.2.3", and "foo:default/1.2.3". Whether ":<config>" and "/<version>" are
required or allowed is dependent upon what your are doing

Standard options:

      [--set <VAR=value>]
      [--append <VAR=val>]
      [--file <path>] [--no-file]
      [--config <config>]
      [--login]
      [--log-level <level>] [--log-config <path>]
      [--figrc <path>] [--no-figrc]

Environment variables:

  FIG_REMOTE_URL (required),
  FIG_HOME (path to local repository cache, defaults to $HOME/.fighome).

  EOF

  LOG_LEVELS = %w[ off fatal error warn info debug all ]
  LOG_ALIASES = { 'warning' => 'warn' }

  attr_reader :descriptor
  attr_reader :exit_code

  def initialize(argv)
    @options = {}

    @options[:home] = ENV['FIG_HOME'] || File.expand_path('~/.fighome')

    parser = new_parser()

    # TODO: Need to catch the exception thrown from parser and retranslate into a fig exception
    begin
      parser.parse!(argv)
    rescue OptionParser::MissingArgument => error
      $stderr.puts "Please provide the #{error}."
      @exit_code = 1
      return
    end

    if not exit_code.nil?
      return
    end

    if argv.size > 1
      $stderr.puts %q<Extra arguments. Should only have a package/version after all other options. Had "> + argv.join(%q<", ">) + %q<" left over.>
      @exit_code = 1
      return
    end

    package_text = argv.first
    if package_text
      @descriptor = Fig::PackageDescriptor.new(package_text)
    end

    return
  end

  def archives()
    return @options[:archives]
  end

  def clean?()
    return @options[:clean]
  end

  def config()
    return @options[:config]
  end

  def figrc()
    return @options[:figrc]
  end

  def force?()
    return @options[:force]
  end

  def get()
    return @options[:get]
  end

  def home()
    return @options[:home]
  end

  def listing()
    return @options[:listing]
  end

  def log_config()
    return @options[:log_config]
  end

  def login?()
    return @options[:login]
  end

  def log_level()
    return @options[:log_level]
  end

  def no_figrc?()
    return @options[:no_figrc]
  end

  def non_command_package_statements()
    return @options[:non_command_package_statements]
  end

  def package_config_file()
    return @options[:package_config_file]
  end

  def publish?()
    return @options[:publish]
  end

  def publish_local?()
    return @options[:publish_local]
  end

  def publishing?()
    return publish? || publish_local?
  end

  def resources()
    return @options[:resources]
  end

  def update?()
    return @options[:update]
  end

  def update_if_missing?()
    return @options[:update_if_missing]
  end

  def updating?()
    return update? || update_if_missing?
  end

  private

  def new_parser
    return OptionParser.new do |opts|
      set_up_queries(opts)
      set_up_commands(opts)
      set_up_package_configuration_source(opts)
      set_up_package_statements(opts)
      set_up_remote_repository_access(opts)
      set_up_program_configuration(opts)
    end
  end

  def set_up_queries(opts)
    opts.banner = USAGE
    opts.on('-?', '-h','--help','display this help text') do
      help(opts)
    end

    opts.on('-v', '--version', 'Print fig version') do
      version()
    end

    opts.on(
      '-g',
      '--get VAR',
      'print value of environment variable VAR'
    ) do |get|
      @options[:get] = get
    end

    set_up_listings(opts)

    return
  end

  def set_up_listings(opts)
    option_mapping = {
      :local_packages =>
        [ '--list-local', '--list', 'list packages in $FIG_HOME' ],

      :configs =>
        ['--list-configs', 'list configurations'],

      :dependencies =>
        ['--list-dependencies', 'list package dependencies, recursively'],

      :dependencies_all_configs =>
        [
          '--list-dependencies-all-configs',
          'list package dependencies, recursively, following all configurations'
        ],

      :variables =>
        [
          '--list-variables',
          'list all variables defined/used by package and its dependencies'
        ],

      :variables_all_configs =>
        [
          '--list-variables-all-configs',
          'list all variables defined/used by package and its dependencies, following all configurations'
        ],

      :remote_packages =>
        ['--list-remote', 'list packages in remote repo']
    }

    option_mapping.each_pair do
      | type, specification |

      opts.on(*specification) do
        @options[:listing] = type
      end
    end

    return
  end

  def set_up_commands(opts)
    opts.on('--clean', 'remove package from $FIG_HOME') do
      @options[:clean] = true
    end

    opts.on(
      '--publish', 'install package in $FIG_HOME and in remote repo'
    ) do |publish|
      @options[:publish] = true
    end

    opts.on(
      '--publish-local', 'install package only in $FIG_HOME'
    ) do |publish_local|
      @options[:publish_local] = true
    end

    return
  end

  def set_up_package_configuration_source(opts)
    @options[:config] = 'default'
    opts.on(
      '-c',
      '--config CFG',
      %q<apply configuration CFG, default is 'default'>
    ) do |config|
      @options[:config] = config
    end

    @options[:package_config_file] = nil
    opts.on(
      '--file FILE',
      %q<read fig file FILE. Use '-' for stdin. See also --no-file>
    ) do |path|
      @options[:package_config_file] = path
    end

    opts.on(
      '--no-file', 'ignore package.fig file in current directory'
    ) do |path|
      @options[:package_config_file] = :none
    end

    return
  end

  def set_up_package_statements(opts)
    @options[:non_command_package_statements] = []
    opts.on(
      '-p',
      '--append VAR=VAL',
      'append (actually, prepend) VAL to environment var VAR, delimited by separator'
    ) do |var_val|
      var, val = var_val.split('=')
      @options[:non_command_package_statements] << Fig::Package::Path.new(var, val)
    end

    opts.on(
      '-i',
      '--include PKG',
      'include PKG (with any variable prepends) in environment'
    ) do |descriptor|
      @options[:non_command_package_statements] <<
        Fig::Package::Include.new(Fig::PackageDescriptor.new(descriptor), {})
    end

    opts.on(
      '-s', '--set VAR=VAL', 'set environment variable VAR to VAL'
    ) do |var_val|
      var, val = var_val.split('=')
      @options[:non_command_package_statements] << Fig::Package::Set.new(var, val)
    end

    @options[:archives] = []
    opts.on(
      '--archive FULLPATH',
      'include FULLPATH archive in package (when using --publish)'
    ) do |path|
      @options[:archives] << Fig::Package::Archive.new(path)
    end

    @options[:resources] =[]
    opts.on(
      '--resource FULLPATH',
      'include FULLPATH resource in package (when using --publish)'
    ) do |path|
      @options[:resources] << Fig::Package::Resource.new(path)
    end

    return
  end

  def set_up_remote_repository_access(opts)
    opts.on(
      '-u',
      '--update',
      'check remote repo for updates and download to $FIG_HOME as necessary'
    ) do
      @options[:update] = true
    end

    opts.on(
      '-m',
      '--update-if-missing',
      'check remote repo for updates only if package missing from $FIG_HOME'
    ) do
      @options[:update_if_missing] = true
    end

    opts.on(
      '-l', '--login', 'login to remote repo as a non-anonymous user'
    ) do
      @options[:login] = true
    end

    @options[:force] = nil
    opts.on(
      '--force',
      'force-overwrite existing version of a package to the remote repo'
    ) do |force|
      @options[:force] = force
    end

    return
  end

  def set_up_program_configuration(opts)
    opts.on(
      '--figrc PATH', 'add PATH to configuration used for Fig'
    ) do |path|
      @options[:figrc] = path
    end

    opts.on('--no-figrc', 'ignore ~/.figrc') { @options[:no_figrc] = true }

    opts.on(
      '--log-config PATH', 'use PATH file as configuration for Log4r'
    ) do |path|
      @options[:log_config] = path
    end

    level_list = LOG_LEVELS.join(', ')
    opts.on(
      '--log-level LEVEL',
      LOG_LEVELS,
      LOG_ALIASES,
      'set logging level to LEVEL',
      "  (#{level_list})"
    ) do |log_level|
      @options[:log_level] = log_level
    end

    return
  end

  def help(opts)
    puts opts.help
    puts "        --                           end of fig options; anything after this is used as a command to run\n\n"

    @exit_code = 0

    return
  end

  def version()
    line = nil

    begin
      File.open(
        "#{File.expand_path(File.dirname(__FILE__) + '/../../VERSION')}"
      ) do |file|
        line = file.gets
      end
    rescue
      $stderr.puts 'Could not retrieve version number. Something has mucked with your fig install.'

      @exit_code = 1
      return
    end

    if line !~ /\d+\.\d+\.\d+/
      $stderr.puts %Q<"#{line}" does not look like a version number. Something has mucked with your fig install.>

      @exit_code = 1
      return
    end

    puts File.basename($0) + ' v' + line

    @exit_code = 0
    return
  end
end
