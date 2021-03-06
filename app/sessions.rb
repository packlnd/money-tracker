module App
  class Sessions < Sinatra::Application
    set :logging, true

    post '/register' do
      user = User.new(params[:user])
      user.username.downcase!
      user.save
      redirect '/auth/login'
    end

    get '/login' do
      haml :'sessions/login'
    end

    post '/login' do
      env['warden'].authenticate!
      redirect '/history'
    end

    get '/register' do
      haml :'sessions/register'
    end

    get '/logout' do
      env['warden'].logout
      redirect '/auth/login'
    end

    post '/unauthenticated' do
      redirect '/auth/login'
    end
  end
end
