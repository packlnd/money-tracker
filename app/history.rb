# -*- encoding : utf-8 -*-
module App
  class History < Sinatra::Application
    before do
      env['warden'].authenticated?
    end

    helpers do
      def month_name(i)
        ['Januari', 'Februari', 'Mars', 'April', 'Maj', 'Juni', 'Juli', 'Augusti', 'September', 'Oktober', 'November', 'December'][i-1]
      end

      def string_to_time(s)
        arr = s.split('-')
        Time.new(arr[0], arr[1], arr[2])
      end
    end

    get '/' do
      @user = env['warden'].user.username
      @transactions = Transaction.order(Sequel.desc(:timestamp)).where(owner: env['warden'].user.username)
      @cat_ids = Array.new()
      @from = string_to_time(Transaction.first_transaction(env['warden'].user.username)) - 1
      @to = string_to_time(Transaction.last_transaction(env['warden'].user.username)) + 3600*24
      (1..Category.count).each do |i|
        @cat_ids.push(i)
      end
      haml :'history/index'
    end

    get '/new_category/:tid/:cid' do
      cid = params[:cid]
      tid = params[:tid]
      Transaction[tid].update(category_id: cid)
      @category = Category.get_category(cid)
      haml :_new_label, :layout => false
    end

    post '/upload' do
      Import.handle_file(params['file'], env['warden'].user.username)
      redirect '/history'
    end

get '/update/:from/:to/:categories' do
      @user = env['warden'].user.username
      @from = string_to_time(params[:from]) - 1
      @to = string_to_time(params[:to]) + 3600*24
      @cat_ids = params[:categories].split('.');
      @transactions = Transaction.order(Sequel.desc(:timestamp)).where(timestamp: @from..@to, owner: env['warden'].user.username, category_id: @cat_ids)
      haml :'history/_table', :layout => false
    end

    get '/update/:from/:to/:categories/:text' do
      @user = env['warden'].user.username
      @from = string_to_time(params[:from]) - 1
      @to = string_to_time(params[:to]) + 3600*24
      @cat_ids = params[:categories].split('.');
      @transactions = Transaction.order(Sequel.desc(:timestamp)).where(Sequel.ilike(:name, "%#{params[:text]}%"), timestamp: @from..@to, owner: env['warden'].user.username, category_id: @cat_ids)
      haml :'history/_table', :layout => false
    end

    get '/:id/delete' do |id|
      Transaction[id].delete
    end

    get '/:id/edit' do |id|
      @t = Transaction[id]
      haml :'history/_edit_row', :layout => false
    end

    get '/:id/:name/save' do
      @t = Transaction[params[:id]]
      @t.update(name: params[:name])
      haml :'history/_display_row', :layout => false
    end
  end
end
