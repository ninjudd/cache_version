require 'rubygems'
require 'test/unit'
require 'shoulda'
require 'mocha'

$LOAD_PATH.unshift File.dirname(__FILE__) + "/../lib"
$LOAD_PATH.unshift File.dirname(__FILE__) + "/../../memcache/lib"

require 'cache_version'

class Test::Unit::TestCase
end

CACHE = MemCache.new(
  :ttl=>1800,
  :compression=>false,
  :readonly=>false,
  :debug=>false,
  :c_threshold=>10000,
  :urlencode=>false
)
ActiveRecord::Base.establish_connection(
  :adapter  => "postgresql",
  :host     => "localhost",
  :username => "postgres",
  :password => "",
  :database => "record_cache_test"
)
ActiveRecord::Migration.verbose = false
ActiveRecord::Base.connection.client_min_messages = 'panic'
