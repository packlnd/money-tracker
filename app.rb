
require 'sinatra'
require 'haml'


get '/' do
	haml :index
end

get '/auth' do
	haml :login
end

