module App
  class Settings < Sinatra::Application
    before do
      env['warden'].authenticate!
    end

    get "/" do
      haml :'settings/index'
    end

    get '/add/:name/:color' do
      category = Category.new(name: params[:name], color: "#" + params[:color], seq_id: "#{Category.last.seq_id + 1}")
      category.save
      haml :'settings/_table', :layout => false
    end

    get '/format/:name/:color' do
      @label_name = params[:name]
      @label_color = params[:color]
      haml :_new_label, :layout => false
    end

    get "/:id/delete" do |id|
      Transaction.where(category_id: id).all.each do |transaction|
        transaction.category_id = 1
      end
      Category[id].delete
      ((id.to_i+1)..Category.count).each do |update_id|
        Category[update_id].seq_id -= 1
      end
      haml :'settings/_table', :layout => false
    end
  end
end
