path = File.expand_path("../", __FILE__)

require 'sinatra'
require "#{path}/app"

set :logging, true

run MoneyTracker