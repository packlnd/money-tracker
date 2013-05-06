# encoding: UTF-8

module App
	class Main < Sinatra::Application
		enable :logging

		get '/' do
			if env['warden'].authenticated?
				redirect '/history'
			else
				haml :index
			end
		end

		get '/statistics' do
			if env['warden'].authenticated?

			end
		end
	end
end