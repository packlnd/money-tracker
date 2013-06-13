module App
  class Settings < Sinatra::Application
    before do
      env['warden'].authenticate!
    end

    get "/" do
      haml :'settings/index'
    end

    get '/add/:name/:color' do
      puts "hello"
      category = Category.new(name: params[:name], color: "#" + params[:color])
      category.save
      haml :'settings/_table'
    end

    get "/:id/edit" do |id|
      
    end

    get "/:id/delete" do |id|
      puts "hello"
      Category[id].delete
      haml :'settings/_table'
    end
  end
end
