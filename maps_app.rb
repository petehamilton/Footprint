get "/map" do
  # Get base API Connection
  @graph  = Koala::Facebook::API.new(session[:facebook_access_token])

  # Get public details of current application
  @app  =  @graph.get_object(ENV["FACEBOOK_APP_ID"])
  puts session.inspect
  if session[:facebook_access_token]
    @checkins = @graph.get_connections('me', 'checkins').map{|c| FacebookCheckin.new(c)}
  else
    redirect '/auth/facebook'
  end
  erb :map
end