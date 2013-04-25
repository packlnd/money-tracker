
require 'sinatra'
require 'haml'


get '/' do
	haml :index
end

get '/login' do
	haml :login
end

