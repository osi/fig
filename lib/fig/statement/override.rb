require 'fig/logging'
require 'fig/packageerror'
require 'fig/statement'

module Fig; end

# Overrides one package version dependency with another in an include
# statement.
#
#    include blah/1.2.3 override somedependency/3.2.6
#
# indicates that, regardless of which version of somedependency the blah
# package says it needs, the blah package will actually use v3.2.6.
class Fig::Statement::Override
  include Fig::Statement

  attr_reader :package_name, :version_name

  def initialize(package_name, version_name)
    @package_name = package_name
    @version_name = version_name
  end

  def unparse()
    return ' override ' + @package_name + '/' + @version_name
  end
end
