module App
	class Statistics < Sinatra::Application

		require 'rchart'

		before do
			env['warden'].authenticate!
		end

		get "/" do 
			p = Rdata.new
			p.add_point([1,4,-3,2,-3,3,2,1,0,7,4], "1")
			p.add_point([3,3,-4,1,-2,2,1,0,-1,6,3], "2")
			p.add_point([4,1,2,-1,-4,-2,3,2,1,2,2], "3")
			p.add_all_series()
			ch = Rchart.new(700,230)

			ch.set_graph_area(50,30,680,200)
			ch.draw_scale(p.get_data,p.get_data_description,Rchart::SCALE_NORMAL,150,150,150,true,0,2,true)
			ch.draw_treshold(0,143,55,72,true,true)

	        ch.draw_legend(596,150,p.get_data_description,255,255,255)
			ch.draw_bar_graph(p.get_data,p.get_data_description)
			ch.render_png("public/images/bar-chart")

			p = Rdata.new
			# Add data
			p.add_point([10,2,3,5,3],"Serie1")
			p.add_point(["Jan","Feb","Mar","Apr","May"],"Serie2")
			p.add_all_series
			p.set_abscise_label_serie("Serie2")

			ch = Rchart.new(300,200)

			# Load palette from array [[r,g,b],[r1,g1,b1]]
			ch.load_color_palette([[168,188,56],[188,208,76],[208,228,96],[228,245,116],[248,255,136]])

			# Draw Basic Pie Graph
			ch.draw_basic_pie_graph(p.get_data,p.get_data_description,120,100,70,Rchart::PIE_PERCENTAGE,255,255,218)
			ch.draw_pie_legend(230,15,p.get_data,p.get_data_description,250,250,250)

			ch.render_png("public/images/basic-pie")

			haml :statistics
		end
	end
end