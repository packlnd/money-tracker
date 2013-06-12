module App
  class Settings < Sinatra::Application
    before do
      env['warden'].authenticate!
    end

    get "/" do
      haml :settings
    end

    get '/add/:name/:color' do
      category = Category.new(name: params[:name], color: "#" + params[:color])
      category.save
      haml :_setting_table
    end

    get "/:id/edit" do |id|
      
    end
  end
end
