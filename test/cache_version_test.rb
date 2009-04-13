require File.dirname(__FILE__) + '/test_helper'

class CacheVersionTest < Test::Unit::TestCase
  context 'with a memcache and db connection' do
    setup do
      system('memcached -d')
      CACHE.servers = ["localhost:11211"]
      CacheVersionMigration.up
    end
    
    teardown do
      system('killall memcached')
      CacheVersionMigration.down
    end

    should 'increment cache version' do
      5.times do |i|
        assert_equal i, Object.version
        Object.increment_version
        assert_equal i + 1, Object.version
      end
      CacheVersion.clear_cache
      assert_equal 5, Object.version
    end
  end
end
