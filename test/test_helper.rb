require 'rubygems'
require 'test/unit'
require 'shoulda'
require 'mocha/setup'

$LOAD_PATH.unshift File.dirname(__FILE__) + "/../lib"
$LOAD_PATH.unshift File.dirname(__FILE__) + "/../../memcache/lib"

require 'cache_version'

class Test::Unit::TestCase
end

CACHE = Memcache.new(:servers => 'localhost')
ActiveRecord::Base.establish_connection(
  :adapter  => "postgresql",
  :host     => "localhost",
  :username => `whoami`.chomp,
  :password => "",
  :database => "test"
)
ActiveRecord::Migration.verbose = false
ActiveRecord::Base.connection.client_min_messages = 'panic'
