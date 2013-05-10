# -*- encoding : utf-8 -*-
module App
	class History < Sinatra::Application

		require 'pry'

		before do
			env['warden'].authenticated?
		end

		get '/' do
			@transactions = Transaction.order(Sequel.desc(:timestamp)).where(:owner => env['warden'].user.username, :timestamp => (Date.today - 14)..(Date.today))
			haml :history
		end

		get '/updateCategory/:id' do |id|
			new_category = (Transaction[id].category_id % Category.count) + 1
			Transaction[id].update(:category_id => new_category)
			redirect '/history'
		end

		post '/upload' do
			if params['file']
				file = File.open(params['file'][:tempfile]).each do |line|
					data = line.delete("\r").delete("\n").split("\t")
					transaction = Transaction.new

					transaction.timestamp = data[0].chomp()
					transaction.name = data[1].chomp()
					transaction.sum = data[2].chomp().delete(" ").gsub(',','.').to_f
					transaction.determine_category
					transaction.owner = env['warden'].user.username
					transaction.save
				end
			end
			redirect '/history'
		end

		post '/update' do
			category_ids = []
			params[:category].each do |cat|
				category_ids << cat[0].to_i
			end
			@transactions = Transaction.order(Sequel.desc(:timestamp)).where(:owner => env['warden'].user.username, :timestamp => (params['date_from'])..(params['date_to']), :category_id => category_ids)
			haml :history
		end

		post '/update/:id' do |id|
			Transaction[id].update(params[:transaction])
			redirect '/history'
		end

		get '/delete/:id' do |id|
			Transaction[id].delete
			redirect '/history'
		end

		get '/edit/:id' do |id|
			@transaction = Transaction[id]
			haml :edit
		end
	end
end