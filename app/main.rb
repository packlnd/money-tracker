# encoding: UTF-8

module App
	class Main < Sinatra::Application

		get '/' do
			if env['warden'].authenticated?
				redirect '/history'
			end
			haml :index
		end
	end
end