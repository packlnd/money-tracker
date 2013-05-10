module App
	class Statistics < Sinatra::Application

		require 'rchart'

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
			Category.all.each do |cat|
				if params[:category][cat.id.to_s] != nil
					categories << cat
				end
			end
			create_statistics categories
			redirect '/statistics'
		end
	end
end