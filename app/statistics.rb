module App
	class Statistics < Sinatra::Application

		require 'rchart'
		require 'pry'

		def create_charts(categories)
			#Graph.create_bar categories, env['warden'].user.username
			Grapher.create_pie categories, env['warden'].user.username
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
			create_charts categories
			redirect '/statistics'
		end
	end
end