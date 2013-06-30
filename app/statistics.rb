module App
  require 'json'
  class Statistics < Sinatra::Application

    before do
      env['warden'].authenticate!
    end

    helpers do
      def string_to_time(s)
        arr = s.split('-')
        Time.new(arr[0], arr[1], arr[2])
      end
    end

    get "/" do
      @user = env['warden'].user.username
      haml :'statistics/index'
    end

    get "/:from/:to/:categories/get_table_data" do
      ids = params[:categories].split('.')
      @user = env['warden'].user.username
      from = string_to_time(params[:from]) - 1
      to = string_to_time(params[:to]) + 3600*24
      @categories = []
      Category.where(seq_id: ids).all.each do |category|
        @categories << [Transaction.where(category_id: category.seq_id, timestamp: from..to, owner: env['warden'].user.username).count, category.seq_id]
      end
      @categories.sort! {|x,y| y <=> x}
      haml :'statistics/_table', :layout => false
    end

    get "/get_monthly_data/:to/:categories" do
      year = params[:to].split('-')[0]
      cat_ids = params[:categories].split('.')
      categories = Hash.new
      cat_ids.each do |cat_id|
        category = Hash.new
        cat = Category.get_category(cat_id)
        category["color"] = cat.color
        month = Hash.new
        (1..12).each do |m|
          month[m-1] = Transaction.get_sum_year_month(year, m, cat_id, env['warden'].user.username)
        end
        category["months"] = month.to_json
        categories[cat.name] = category.to_json
      end
      categories.to_json
    end

    get "/get_pie_data/:from/:to/:categories" do
      from = string_to_time(params[:from]) - 1
      to = string_to_time(params[:to]) + 3600*24
      category_ids = params[:categories].split('.')
      categories = Hash.new
      category_ids.each do |cat_id|
        cat = Category.get_category(cat_id)
        category = Hash.new
        category["sum"] = Transaction.get_sum(cat.seq_id, from, to, env['warden'].user.username).to_i.abs
        category["color"] = cat.color
        categories[cat.name] = category.to_json
      end
      categories.to_json
    end
  end
end
