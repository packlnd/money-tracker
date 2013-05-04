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

	get '/' do
		if env['warden'].authenticated?
			haml :history
		else
			haml :index
		end
	end

	get '/register' do
		haml :register
	end

	get '/history' do
		if env['warden'].authenticated?
			haml :history
		end
	end

	post '/upload' do
		if params['myFile']
			file = File.open(params['myFile'][:tempfile], :encoding => 'windows-1251:utf-8').each do |line|
				data = line.encode('UTF-8').delete("\r").delete("\n").split("\t")
				transaction = Transaction.new
				transaction.timestamp = data[0].chomp()
				transaction.name = data[1].chomp()
				transaction.category = determine_category(data[0].chomp(), data[1].chomp(), data[2].delete(" ").chomp().to_f)
				transaction.sum = data[2].chomp().delete(" ").to_f
				transaction.owner = env['warden'].user.username
				transaction.save
			end
		end
		redirect '/history'
	end

	post '/:id' do |id|
		transaction = Transaction[id]
		transaction.name = params[:name]
		transaction.category = params[:category]
		transaction.save
		redirect '/history'
	end

	def determine_category(date, name, sum)
		if sum > 0
			return 1
		else
			return 0
		end
	end

	def i_to_category(i)
		if i == 1
			return "Inkomst"
		end
		return "Utgift"
	end

	get '/delete/:id' do |id|
		if env['warden'].authenticated?
			Transaction[id].delete
		end
		redirect '/history'
	end

	get '/edit/:id' do |id|
		if env['warden'].authenticated?
			@transaction = Transaction[id]
			haml :edit
		end
	end

	get '/statistics' do
		if env['warden'].authenticated?

		end
	end

	post '/register' do
		user = User.new
		user.username = params[:username]
		user.password = params[:password]
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
			params['username'] || params['password']
		end

		def authenticate!
			user = User[:username => params['username']]
			if user && user.password == params['password']
				success!(user)
			else
				fail!("could not log in")	
			end
		end
	end
end