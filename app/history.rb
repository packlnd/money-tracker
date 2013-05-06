require 'pry'

module App
	class History < Sinatra::Application
		before do
			env['warden'].authenticate!
			@categories = ["UTGIFT", "INKOMST", "MAT OCH DRYCK", "FRITID", "BANKOMAT", "TRANSPORT"]
			@cssCategories = ['label', 'label label-success', 'label label-warning', 'label label-info', 'label label-inverse', 'label label-important']
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

			def css_category(i)
				return @cssCategories[i]
			end
		end

		get '/' do
			haml :history
		end

		get '/updateCategory/:id' do |id|
			transaction = Transaction[id]
			transaction.category = (transaction.category + 1) % @categories.length
			transaction.save
			redirect '/history'
		end

		post '/upload' do
			if params['myFile']
				file = File.open(params['myFile'][:tempfile]).each do |line|
					data = line.delete("\r").delete("\n").split("\t")
					transaction = Transaction.new

					transaction.timestamp = data[0].chomp()
					transaction.name = data[1].chomp()
					transaction.sum = data[2].chomp().delete(" ").gsub(',','.').to_f
					transaction.category = determine_category(transaction)
					transaction.owner = env['warden'].user.username
					transaction.save
				end
			end
			redirect '/history'
		end

		post '/update/:id' do |id|
			Transaction[id].update(params[:transaction])
			redirect '/history'
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
	end
end