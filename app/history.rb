# -*- encoding : utf-8 -*-
module App

  require 'pry'

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
      @first = string_to_time(Transaction.first_transaction(env['warden'].user.username))
      @last = string_to_time(Transaction.last_transaction(env['warden'].user.username))
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
      haml :'util/_category_label', :layout => false
    end

    post '/upload' do
      Import.handle_file(params['file'], env['warden'].user.username)
      redirect '/history'
    end

get '/update/:from/:to/:categories' do
      @user = env['warden'].user.username
      @first = string_to_time(params[:from])
      @last = string_to_time(params[:to])
      @cat_ids = params[:categories].split('.');
      haml :'history/_table', :layout => false
    end

    get '/update/:from/:to/:categories/:text' do
      @user = env['warden'].user.username
      @first = string_to_time(params[:from])
      @last = string_to_time(params[:to])
      @cat_ids = params[:categories].split('.');
      @filter_text = params[:text]
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
