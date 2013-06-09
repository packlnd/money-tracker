# -*- encoding : utf-8 -*-
module App
  class History < Sinatra::Application

    require 'pry'

    before do
      env['warden'].authenticated?
    end

    get '/' do
      @transactions = Transaction.order(Sequel.desc(:timestamp)).where(:owner => env['warden'].user.username)
      @cat_ids = Array.new(Category.count, 0)
      for i in 1..Category.count
        @cat_ids[i-1] = i
      end
      haml :history
    end

    get '/updateCategory/:id' do |id|
      new_category = (Transaction[id].category_id % Category.count) + 1
      Transaction[id].update(:category_id => new_category)
      redirect '/history'
    end

    post '/upload' do
      Transaction.handle_file(params['file'], env['warden'].user.username)
      redirect '/history'
    end

    get '/update/:from/:to/:categories' do
      from_date = params[:from].split('-')
      @from = Time.new(from_date[0], from_date[1], from_date[2]) - 1
      to_date = params[:to].split('-')
      @to = Time.new(to_date[0], to_date[1], to_date[2]) + 3600*24
      @cat_ids = params[:categories].split('.');
      @transactions = Transaction.order(Sequel.desc(:timestamp)).where(:timestamp => @from..@to,:owner => env['warden'].user.username, :category_id => @cat_ids)
      haml :table
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
      haml :edit
    end
  end
end
