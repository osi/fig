require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

require 'stringio'
require 'tempfile'

require 'fig/figrc'
require 'fig/repository'
require 'fig/retriever'

def create_override_file(foo, bar = nil)
    tempfile = Tempfile.new('some_json_tempfile')
    tempfile << %Q< { "foo" : "#{foo}" >
    if not bar.nil?
      tempfile << %Q< , "bar" : "#{bar}" >
    end
    tempfile << %Q< } >
    tempfile.close
    return tempfile
end

def create_remote_config(foo, bar = nil)
    FileUtils.mkdir_p(
      File.join(FIG_REMOTE_DIR, Fig::Repository::METADATA_SUBDIRECTORY)
    )
    figrc_path = File.join(FIG_REMOTE_DIR, Fig::FigRC::REPOSITORY_CONFIGURATION)
    file_handle = File.new(figrc_path,'w')
    file_handle.write( %Q< { "foo" : "#{foo}" > )
    if not bar.nil?
      file_handle.write( %Q< , "bar" : "#{bar}" > )
    end
    file_handle.write( %Q< } > )
    file_handle.close
    return
end

describe 'FigRC' do
  before(:all) do
    setup_test_environment
  end

  after(:each) do
    cleanup_test_environment
  end

  it 'handles override path with a remote repository' do
    tempfile = create_override_file('loaded as override')

    create_remote_config("loaded from repository (shouldn't be)")
    configuration = Fig::FigRC.find(tempfile.path, ENV['FIG_REMOTE_URL'], true, ENV['FIG_HOME'], true)
    tempfile.unlink

    configuration['foo'].should == 'loaded as override'
  end

  it 'handles no override, no repository (full stop)' do
    configuration = Fig::FigRC.find(nil, nil, true, ENV['FIG_HOME'], true)
    configuration['foo'].should == nil
  end

  it 'handles no repository config and no override specified, and config does NOT exist on server' do
    configuration = Fig::FigRC.find(nil, %Q<file:///does_not_exist/>, true, ENV['FIG_HOME'], true)
    configuration['foo'].should == nil
  end

  it 'retrieves configuration from repository with no override' do
    create_remote_config('loaded from repository')

    configuration = Fig::FigRC.find(nil, ENV['FIG_REMOTE_URL'], true, ENV['FIG_HOME'], true)
    configuration['foo'].should == 'loaded from repository'
  end

  it 'has a remote config but gets its config from the override file provided' do
    create_remote_config('loaded from remote repository')
    tempfile = create_override_file('loaded as override to override remote config')
    configuration = Fig::FigRC.find(tempfile.path, ENV['FIG_REMOTE_URL'], true, ENV['FIG_HOME'], true)
    configuration['foo'].should == 'loaded as override to override remote config'
  end

  it 'merges override file config over remote config' do
    create_remote_config('loaded from remote repository','should not be overwritten')
    tempfile = create_override_file('loaded as override to override remote config')
    configuration = Fig::FigRC.find(tempfile.path, ENV['FIG_REMOTE_URL'], true, ENV['FIG_HOME'], true)
    configuration['foo'].should == 'loaded as override to override remote config'
    configuration['bar'].should == 'should not be overwritten'
  end
end
