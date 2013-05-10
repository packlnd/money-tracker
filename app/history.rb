# -*- encoding : utf-8 -*-
module App
	class History < Sinatra::Application
		before do
			env['warden'].authenticated?
		end

		get '/' do
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