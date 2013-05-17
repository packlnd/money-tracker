module App
  class Statistics < Sinatra::Application

    before do
      env['warden'].authenticate!
    end

    get "/" do 
      haml :statistics
    end

#    post "/update" do
#      categories = []
#      params[:category].each do |cat|
#        categories << Category[cat[0].to_i]
#      end
#      from = Time.new(params['date_from']) - 1
#      to = Time.new(params['date_to']) + 3600*24
#      create_statistics(categories, from, to)
#      redirect '/statistics'
#    end
  end
end