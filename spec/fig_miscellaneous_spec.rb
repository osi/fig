require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe 'Fig' do
  before(:each) do
    cleanup_test_environment
    setup_test_environment
  end

  it 'ignores comments' do
    input = <<-END
      #/usr/bin/env fig

      # Some comment
      config default
        set FOO=BAR # Another comment
      end
    END
    FileUtils.mkdir_p(FIG_SPEC_BASE_DIRECTORY)
    fig('--get FOO', input)[0].should == 'BAR'
  end

  it 'prints the version number' do
    %w/-v --version/.each do |option|
      (out, err, exitstatus) = fig(option)
      exitstatus.should == 0
      err.should == ''
      out.should =~ / \d+ \. \d+ \. \d+ /x
    end
  end
end
