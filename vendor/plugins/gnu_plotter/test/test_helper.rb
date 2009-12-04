require 'rubygems'

require File.join(File.dirname(__FILE__), '../init.rb')
Dir[File.join(File.dirname(__FILE__), '../lib/*.rb')].each { |file| require file }

require 'test/unit'