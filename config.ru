require 'sinatra'
require 'haml'
require 'warden'
require 'sequel'
require File.dirname(__FILE__) + '/boot.rb'

use Rack::Session::Cookie, secret: "mycookie"

use Warden::Manager do |manager|
  manager.default_strategies :password
  manager.failure_app = App::Sessions
  manager.serialize_into_session {|user| user.id}
  manager.serialize_from_session {|id| User[id]}
end

Warden::Manager.before_failure do |env,opts|
  env['REQUEST_METHOD'] = 'POST'
end

Warden::Strategies.add(:password) do
  def valid?
    params['user']['username'] || params['user']['password']
  end

  def authenticate!
    user = User[:username => params['user']['username'].downcase!]
    if user && user.password == params['user']['password']
      success!(user)
    else
      fail!("could not log in")
    end
  end
end

map "/" do
  run App::Main
end

map "/history" do
  run App::History
end

map "/auth" do
  run App::Sessions
end

map "/statistics" do
  run App::Statistics
end

map "/settings" do
  run App::Settings
end
