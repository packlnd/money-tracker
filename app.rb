
require 'sinatra'
require 'haml'
require 'warden'
require 'sequel'

Dir.glob('models/*.rb').each do |model|
	require_relative model
end

class MoneyTracker < Sinatra::Application
	use Rack::Session::Cookie, secret: "mycookie"

	get '/' do
		haml :index
	end

	get '/register' do
		haml :register
	end

	post '/register' do
		user = User.new
		user.username = params[:username]
		user.password = params[:password]
		user.save
		redirect '/login'
		binding.pry
		redirect '/bueno'
	end

	get '/login' do
		haml :login
	end

	post '/login' do
		env['warden'].authenticate!
		redirect '/success'
	end

	get '/logout' do
		env['warden'].logout
		redirect '/login'
	end

	post '/unauthenticated' do
		redirect '/failure'
	end

	use Warden::Manager do |manager|
		manager.default_strategies :password
		manager.failure_app = MoneyTracker
		manager.serialize_into_session {|user| user.id}
		manager.serialize_from_session {|id| User[id]}
	end

	Warden::Manager.before_failure do |env,opts|
		env['REQUEST_METHOD'] = 'POST'
	end

	Warden::Strategies.add(:password) do
		def valid?
			params['username'] || params['password']
		end

		def authenticate!
			user = User[:username => params['username']]
			if user && user.authenticate(params['password'])
				success!(user)
			else
				fail!("could not log in")	
			end
		end
	end
end