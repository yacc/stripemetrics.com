Resque::Server.use(Rack::Auth::Basic) do |user, password|  
  user == 'leboss' && password == 'u2canSee!'
end  