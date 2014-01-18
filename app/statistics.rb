module App
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

    get "/get_monthly_data/:to/:categories" do
      year = params[:to].split('-')[0]
      category_ids = params[:categories].split('.')
      Graph.monthly_data(year, category_ids, env['warden'].user.username)
    end

    get "/get_pie_data/:from/:to/:categories" do
      from = string_to_time(params[:from]) - 1
      to = string_to_time(params[:to]) + 3600*24
      category_ids = params[:categories].split('.')
      Graph.pie_data(from, to, category_ids, env['warden'].user.username)
    end
  end
end
