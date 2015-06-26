source 'https://rubygems.org'

def windows_only(require_as)
  RbConfig::CONFIG['host_os'] =~ /mingw|mswin/i ? require_as : false
end
def linux_only(require_as)
  RbConfig::CONFIG['host_os'] =~ /linux/ ? require_as : false
end
def darwin_only(require_as)
  RbConfig::CONFIG['host_os'] =~ /darwin/ ? require_as : false
end

gem 'sinatra'
gem 'thin'
gem 'haml'
gem 'sass'
gem 'activesupport'
gem 'activerecord'
gem 'stellar-base'
# gem 'stellar-base', path: "../ruby-stellar-base"
gem 'sqlite3'
gem 'pg'
gem 'rake'
gem 'dotenv'
gem 'memoist'
gem 'excon'
gem 'awesome_print'
gem 'rack-flash3'

group :development do
  gem 'rerun'
  gem 'pry'

  gem 'better_errors'
  gem 'binding_of_caller'
  gem 'rb-fsevent', :require => darwin_only('rb-fsevent')

  gem 'stellar_core_commander', path: "../stellar_core_commander"
end
