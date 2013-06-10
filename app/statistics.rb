module App
  require 'json'
  class Statistics < Sinatra::Application

    before do
      env['warden'].authenticate!
    end

    helpers do
      def to_hex(rgb)
        colors = rgb.split(',')
        return "#%02X%02X%02X" % [colors[0].to_i, colors[1].to_i, colors[2].to_i]
      end
    end

    get "/" do
      haml :statistics
    end

    get "/get_monthly_data/:from/:to/:categories" do
      
    end

    get "/get_pie_data/:from/:to/:categories" do
      from = params[:from]
      to = params[:to]
      category_ids = params[:categories].split('.');
      hash = Hash.new()
      category_ids.each do |cat_id|
        cat = Category[cat_id]
        category = Hash.new
        category["sum"] = Transaction.get_sum(cat_id, env['warden'].user.username, from, to).to_i.abs
        category["color"] = to_hex(cat.color)
        hash[cat.name] = category.to_json
      end
      hash.to_json
    end
  end
end
