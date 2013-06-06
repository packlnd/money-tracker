# -*- encoding : utf-8 -*-
module App
  class History < Sinatra::Application
    
    require 'pry'

    before do
      env['warden'].authenticated?
    end

    get '/' do
      @transactions = Transaction.order(Sequel.desc(:timestamp)).where(:owner => env['warden'].user.username)
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

    post '/update' do
      category_ids = []
      params[:category].each do |cat|
        category_ids << cat[0].to_i
      end
      from_date = params['date_from'].split('-')
      from = Time.new(from_date[0], from_date[1], from_date[2]) - 1
      to_date = params['date_to'].split('-')
      to = Time.new(to_date[0], to_date[1], to_date[2]) + 3600*24
      @transactions = Transaction.order(Sequel.desc(:timestamp)).where(:owner => env['warden'].user.username, :timestamp => (from)..(to), :category_id => category_ids)
      @cat_ids = category_ids
      haml :history
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
