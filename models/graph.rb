class Grapher
	def self.create_bar(categories, user, from, to)
		p = Rdata.new
		colors = []
		categories.each do |category|
			sums = Array.new(12, 0)
			colors << category.get_color
			Transaction.where(:owner => user, :category_id => category.id, :timestamp => (from)..(to)).all.each do |transaction|
				sums[transaction.timestamp.month.to_i - 1] += transaction.sum.to_i.abs
			end
			p.add_point(sums, category.name.to_s)
		end

		p.add_all_series()

		ch = Rchart.new(700,230)
		ch.set_graph_area(50,30,680,200)
		ch.draw_scale(p.get_data,p.get_data_description,Rchart::SCALE_NORMAL,150,150,150,true,0,2,true)
		ch.draw_treshold(0,143,55,72,true,true)
		ch.load_color_palette(colors)
		ch.draw_bar_graph(p.get_data,p.get_data_description)

		ch.render_png("public/images/bar")
	end

	def self.create_pie(categories, user, from, to)
		sums = []
		names = []
		colors = []
		categories.each do |cat|
			sum = Transaction.where(:category_id => cat.id, :owner => user, :timestamp => (from)..(to)).sum(:sum).to_i.abs
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

		ch = Rchart.new(700,400)
		ch.set_font_properties("tahoma.ttf", 12)

		ch.load_color_palette(colors)
		ch.draw_basic_pie_graph(p.get_data,p.get_data_description,300,200,120,Rchart::PIE_LABELS)

		ch.render_png("public/images/pie")
	end
end