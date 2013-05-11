module App
	class Statistics < Sinatra::Application

		require 'rchart'
		require 'pry'

		def create_charts(categories, from, to)
			Grapher.create_bar(categories, env['warden'].user.username, from, to)
			if categories.count > 1
				Grapher.create_pie(categories, env['warden'].user.username, from, to)
			end
		end

		def create_statistics(categories, from, to)
			create_charts(categories, from, to)
		end

		before do
			env['warden'].authenticate!
		end

		get "/" do 
			haml :statistics
		end

		post "/update" do
			categories = []
			params[:category].each do |cat|
				categories << Category[cat[0].to_i]
			end
			create_statistics(categories, params['date_from'], params['date_to'])
			redirect '/statistics'
		end
	end
end