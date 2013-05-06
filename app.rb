# encoding: UTF-8

require 'sinatra'
require 'haml'
require 'warden'
require 'sequel'
require 'pry'

Dir.glob('models/*.rb').each do |model|
	require_relative model
end

class MoneyTracker < Sinatra::Application
	use Rack::Session::Cookie, secret: "mycookie"

	before do
		@categories = ["UTGIFT", "INKOMST", "MAT OCH DRYCK", "FRITID", "BANKOMAT", "TRANSPORT"]
	end

	helpers do	
		def determine_class(sum)
			if sum >= 0
				return "pos"
			end
			return "neg"
		end

		def determine_category(transaction)
			if transaction.sum > 0
				return 1
			elsif transaction.sum > -100
				return 2
			elsif transaction.sum % 100 == 0 and 
				transaction.sum >= -500 and 
				transaction.sum <= -100
				return 4
			else
				return 0
			end
		end

		def i_to_category(i)
			return @categories[i]
		end
	end

	get '/' do
		if env['warden'].authenticated?
			redirect '/history'
		else
			haml :index
		end
	end

	get '/register' do
		haml :register
	end


	get '/statistics' do
		if env['warden'].authenticated?

		end
	end

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
			params['user']['username'] || params['user']['password']
		end

		def authenticate!
			user = User[:username => params['user']['username']]
			if user && user.password == params['user']['password']
				success!(user)
			else
				fail!("could not log in")	
			end
		end
	end
end