
require 'sinatra'
require 'haml'
require 'warden'
require 'sequel'

Dir.glob('models/*.rb').each do |model|
	require_relative model
end

class MoneyTracker < Sinatra::Application
	use Rack::Session::Cookie

	get '/' do
		haml :index
	end

	get '/register' do
		@user = User.new
		haml :register
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
		manager.serialize_from_session {|id| User.for(:user).find_by_id(id)}
	end

	Warden::Manager.before_failure do |env,opts|
		env['REQUEST_METHOD'] = 'POST'
	end

	Warden::Strategies.add(:password) do
		def valid?
			params["username"] || params["password"]
		end

		def authenticate!
			user = User[0]
			if user && user.authenticate(params['password'])
				success!(user)
			else
				fail!("could not log in")	
			end
		end
	end
end