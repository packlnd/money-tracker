
require 'sinatra'
require 'haml'
require 'warden'

class MoneyTracker < Sinatra::Application
	use Rack::Session::Cookie

	get '/' do
		haml :index
	end

	get '/login' do
		haml :login
	end

	post '/login' do
		env['warden'].authenticate!
		redirect '/'
	end

	get '/logout' do
		env['warden'].logout
		redirect '/login'
	end

	post '/unauthenticated' do
		redirect '/'
	end

	use Warden::Manager do |manager|
		manager.default_strategies :password
		manager.failure_app = MoneyTracker
		manager.serialize_into_session {|user| user.id}
		manager.serialize_from_session {|id| Datastore.for(:user).find_by_id(id)}
	end

	Warden::Manager.before_failure do |env,opts|
		env['REQUEST_METHOD'] = 'POST'
	end

	Warden::Strategies.add(:password) do
		def valid?
			parms["username"] || params["password"]
		end

		def authenticate!
			user = Datastore.for(:user).find_by_email(params['email'])
			if user && user.authenticate(params['password'])
				success!(user)
			else
				fail!("could not log in")	
			end
		end
	end
end


