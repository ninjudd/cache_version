require File.dirname(__FILE__) + '/test_helper.rb'

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

class CacheVersionTest < Test::Unit::TestCase
  def setup
    system('memcached -d')
    CACHE.servers = ["localhost:11211"]

    CacheVersionMigration.up
  end
    
  def teardown
    system('killall memcached')
      
    CacheVersionMigration.down
  end

  def test_get_and_increment
    5.times do |i|
      assert_equal i, Object.version
      Object.increment_version
      assert_equal i + 1, Object.version
    end
    CacheVersion.clear_cache
    assert_equal 5, Object.version
  end
end
