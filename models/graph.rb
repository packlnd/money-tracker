class Grapher < Sinatra::Application

	require 'pry'
	
	def self.create_bar(categories, user)
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

		ch.render_png("public/images/bar")
	end

	def self.create_pie(categories, user)
		sums = []
		names = []
		colors = []
		categories.each do |cat|
			sum = Transaction.where(:category_id => cat.id, :owner => user).sum(:sum).to_i
			if sum == nil
				sum = 0
			end
			names << cat.name + '(' + sum.to_s + ')'
			sums << sum
			colors << cat.get_color
		end

		p = Rdata.new
		p.add_point(sums, "Sums")
		p.add_point(names, "Names")
		p.add_all_series
		p.set_abscise_label_serie("Names")

		ch = Rchart.new(700,600)
		ch.set_font_properties("tahoma.ttf", 12)

		ch.load_color_palette(colors)
		ch.draw_basic_pie_graph(p.get_data,p.get_data_description,300,200,120,Rchart::PIE_LABELS)

		ch.render_png("public/images/pie")
	end
end