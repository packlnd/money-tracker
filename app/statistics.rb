module App
  class Statistics < Sinatra::Application

    require 'pry'

    before do
      env['warden'].authenticate!
    end

    get "/" do 
      haml :statistics
    end

    post "/update" do
      
    end
  end
end