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

	get '/updateCategory/:id' do |id|
		transaction = Transaction[id]
		transaction.category = (transaction.category + 1) % 6
		transaction.save
		redirect 'history'
	end

	post '/upload' do
		if params['myFile']
			file = File.open(params['myFile'][:tempfile], :encoding => 'windows-1251:utf-8').each do |line|
				data = line.encode('UTF-8').delete("\r").delete("\n").split("\t")
				transaction = Transaction.new

				transaction.timestamp = data[0].chomp()
				transaction.name = data[1].chomp()
				transaction.sum = data[2].chomp().delete(" ").gsub!(',','.').to_f
				transaction.category = determine_category(transaction)
				transaction.owner = env['warden'].user.username
				transaction.save
			end
		end
		redirect '/history'
	end

	post '/update/:id' do |id|
		transaction = Transaction[id]
		transaction.name = params[:name]
		transaction.category = params[:category]
		transaction.save
		redirect '/history'
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
		categories = ["UTGIFT", "INKOMST", "MAT OCH DRYCK", "FRITID", "BANKOMAT", "TRANSPORT"]
		return categories[i]
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