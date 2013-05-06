module App
	class Statistics < Sinatra::Application
		
		before do
			env['warden'].authenticate!
		end

		get "/" do 

		end
	end
end