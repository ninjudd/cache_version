require 'test/unit'
require 'rubygems'
require 'mocha'
require 'pp'

$:.unshift(File.dirname(__FILE__) + '/../../memcache/lib')

require File.dirname(__FILE__) + '/../lib/cache_version'
