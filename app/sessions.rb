module App
	class Sessions < Sinatra::Application

		set :logging, true
		
		post '/register' do
			user = User.new(params[:user])
			user.save
			redirect '/login'
		end

		get '/login' do
			haml :login
		end

		post '/login' do
			env['warden'].authenticate!
			redirect '/history'
		end

		get '/register' do
			haml :register
		end

		get '/logout' do
			env['warden'].logout
			redirect '/login'
		end

		post '/unauthenticated' do
			redirect '/failure'
		end	
	end
end