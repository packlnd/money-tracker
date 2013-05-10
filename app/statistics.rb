module App
	class Statistics < Sinatra::Application

		require 'rchart'
		require 'pry'

		def create_charts(categories)
			#Graph.create_bar categories, env['warden'].user.username
			Grapher.create_pie categories, env['warden'].user.username
		end

		def create_statistics(categories)
			create_charts categories
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
			create_statistics categories
			redirect '/statistics'
		end
	end
end