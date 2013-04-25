require 'rubygems'
require 'memcache'
require 'active_record'

module CacheVersion
  def self.db
    db = ActiveRecord::Base.connection
    db = db.send(:master) if defined?(DataFabric::ConnectionProxy) and db.kind_of?(DataFabric::ConnectionProxy)
    db
  end

  def self.cache
    CACHE
  end

  def self.get(key)
    key = key.to_s
    version_by_key[key] ||= CACHE.get_or_add(cache_key(key)) do
      db.select_value("SELECT version FROM cache_versions WHERE #{key_column} = '#{key}'").to_i
    end
  end

  def self.increment(key)
    alter(key, 1, 'version + 1')
  end

  def self.set(key, value)
    alter(key, value.to_i)
  end

  def self.invalidate_cache(key)
    key = key.to_s
    cache.delete(cache_key(key))
    version_by_key.delete(key)
  end

  def self.clear_cache(force = false)
    if v = cache.get(vkey)
      if force == true or @version.nil? or v > @version
        @version = v
        version_by_key.clear
      end
    else
      @version = cache.get_or_add(vkey, Time.now.to_i)
    end
  end

private

  def self.alter(key, init, update = init)
    key = key.to_s

    if get(key) == 0
      db.execute("INSERT INTO cache_versions (#{key_column}, version) VALUES ('#{key}', #{init})")
    else
      db.execute("UPDATE cache_versions SET version = #{update} WHERE #{key_column} = '#{key}'")
    end

    cache.set(vkey, Time.now.to_i)
    invalidate_cache(key)
    get(key)
  end

  def self.version_by_key
    @version_by_key ||= {}
  end

  def self.cache_key(key)
    "v:#{key}"
  end

  def self.vkey
    "v:CacheVersion"
  end

  def self.key_column
    @key_column ||= db.quote_column_name('key')
  end
end

class Module
  def version(context = nil)
    key = [self, context].compact.join('_')
    CacheVersion.get(key)
  end

  def increment_version(context = nil)
    key = [self, context].compact.join('_')
    CacheVersion.increment(key)
  end

  def set_version(value, context = nil)
    key = [self, context].compact.join('_')
    CacheVersion.set(key, value)
  end
end

class CacheVersionMigration < ActiveRecord::Migration
  def self.up
    create_table :cache_versions, :id => false do |t|
      t.column :key, :string
      t.column :version, :integer, :default => 0
    end

    add_index :cache_versions, :key, :unique => true
  end

  def self.down
    drop_table :cache_versions
  end
end
