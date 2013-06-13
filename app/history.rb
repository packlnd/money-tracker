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
      @transactions = Transaction.order(Sequel.desc(:timestamp)).where(:owner => env['warden'].user.username)
      @cat_ids = Array.new()
      @from = string_to_time(Transaction.first_transaction(env['warden'].user.username)) - 1
      @to = string_to_time(Transaction.last_transaction(env['warden'].user.username)) + 3600*24
      (1..Category.count).each do |i|
        @cat_ids.push(i)
      end
      haml :'history/index'
    end

    get '/update_category/:id' do |id|
      new_category = (Transaction[id].category_id % Category.count) + 1
      Transaction[id].update(:category_id => new_category)
      redirect '/history'
    end

    post '/upload' do
      Transaction.handle_file(params['file'], env['warden'].user.username)
      redirect '/history'
    end

    get '/update/:from/:to/:categories' do
      @user = env['warden'].user.username
      @from = string_to_time(params[:from]) - 1
      @to = string_to_time(params[:to]) + 3600*24
      @cat_ids = params[:categories].split('.');
      @transactions = Transaction.order(Sequel.desc(:timestamp)).where(:timestamp => @from..@to,:owner => env['warden'].user.username, :category_id => @cat_ids)
      haml :'history/_table'
    end

    post '/update/:id' do |id|
      Transaction[id].update(params[:transaction])
      redirect '/history'
    end

    get '/delete/:id' do |id|
      Transaction[id].delete
      redirect '/history'
    end

    get '/edit/:id' do |id|
      @transaction = Transaction[id]
      haml :'history/edit'
    end
  end
end
