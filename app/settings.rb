module App
  class Settings < Sinatra::Application
    before do
      env['warden'].authenticate!
    end

    get "/" do
      @user = env['warden'].user
      haml :'settings/index'
    end

    get '/:id/edit' do
      @category = Category.get_category(params[:id])
      @title = "Redigera kategori: #{@category.name}"
      @button_title = "Spara"
      @action = "update"
      haml :'settings/_edit_label', :layout => false
    end

    get '/update/:id/:name/:color' do
      Category.get_category(params[:id]).update(name: params[:name], color: "##{params[:color]}")
      haml :'settings/_table', :layout => false
    end

    get '/add/:name/:color' do
      category = Category.new(name: params[:name], color: "##{params[:color]}", seq_id: "#{Category.last.seq_id + 1}")
      category.save
      haml :'settings/_table', :layout => false
    end

    get '/format/:name/:color' do
      @category = Category.new(name: params[:name], color: "##{params[:color]}")
      haml :'util/_category_label', :layout => false
    end

    get "/:boolean/radio" do |value|
      user = env['warden'].user
      user.set_all_categories = value
      user.save
    end

    get "/:id/delete" do |id|
      Transaction.where(category_id: id).all.each do |transaction|
        transaction.category_id = 1
        transaction.save
      end
      Category.get_category(id).delete
      ((id.to_i+1)..Category.count).each do |update_id|
        category = Category.get_category(update_id)
        new_id = category.seq_id - 1
        category.seq_id = new_id
        category.save
      end
      haml :'settings/_table', :layout => false
    end
  end
end
